#include <algorithm>
#include <list>
#include <string>

#include <conio.h>

#include <boost/numeric/ublas/matrix.hpp>
#include <boost/lambda/lambda.hpp>

#define SQR(x) ((x)*(x))

namespace Options {
	using namespace boost::numeric;

	class OptionException {
	private:
		std::string _description;
	public:
		OptionException() : _description("") {}
		OptionException(std::string& descr) : _description(descr) {}
		OptionException(const char* descr) {
			_description.assign(descr, strlen(descr));
		}
		inline const std::string& Message() const { return _description; };
	};

	class Unsupported : public OptionException {
	public:
		Unsupported() : OptionException() {}
		Unsupported(std::string& descr) : OptionException(descr) {}
		Unsupported(const char* descr) : OptionException(descr) {}
	};

	class Option {
	public:
		enum Kind { Call, Put };
		enum PaymentType { European, American };
	protected:
		double _strike;
		Kind _kind;
		PaymentType _type;
		double _term;
	public:
		Option() : _strike(0), _kind(Call), _term(0), _type(European) {}
		Option(double strike, Kind kind, double term, PaymentType type = European) : 
			_strike(strike), _kind(kind), _term(term), _type(type) {}

		inline PaymentType GetPaymentType() const { return _type; }
		inline double GetStrike() const { return _strike; }
		inline Kind GetKind() const { return _kind; }
		inline double GetTerm() const { return _term; }

		virtual double payoff(double price) const = 0;
	};

	class VanillaOption : public Option {
	public:
		VanillaOption(double strike, Kind kind, double term, PaymentType type = European) : Option(strike, kind, term, type) {}

		inline virtual double payoff(double price) const { 
			if (_kind == Call) {
				return std::max(price - _strike, 0.0);
			} else {
				return std::max(_strike - price, 0.0);
			}
		}
	};

	class DigitalOption : public Option {
	public:
		DigitalOption(double strike, Kind kind, double term, PaymentType type = European) : Option(strike, kind, term, type) {}

		inline virtual double payoff(double price) const { 
			if (_kind == Call) {
				return (price > _strike, 1.0, -1);
			} else {
				return (price < _strike, 1.0, -1);
			}
		}
	};

	class Volatility {
	public:
		virtual double volatility() const = 0;
	};

	class ConstantVolatility : public Volatility {
	private:
		double _vol;
	public:
		ConstantVolatility() : _vol(0) {}
		ConstantVolatility(double vol) : _vol(vol) {}

		inline virtual double volatility() const { return _vol; };
	};

	class UncertainVolatility : Volatility {
	private:
		double _volMin, _volMax;
		double _gamma;
	public:
		UncertainVolatility() : _volMin(0), _volMax(0), _gamma(0) {}
		UncertainVolatility(double volMin, double volMax, double gamma) : _volMin(volMin), _volMax(volMax), _gamma(gamma) {}
		inline void SetGamma(double gamma) { _gamma = gamma; }
		inline virtual double volatility() const { return (_gamma < 0 ? _volMin : _volMax); }
		inline double GetMinVol() const { return _volMin; }
		inline double GetMaxVol() const { return _volMax; }
	};

	class OptionPack {
	private:
		std::list<Option*> _options;
		double _spot;
		double _rfr;
		Volatility* _vol;

	public:
		inline double GetSpot() const { return _spot; }
		inline double GetRFR() const { return _rfr; }
		inline const Volatility* GetVolatility() const { return _vol; }

		OptionPack(double spot, double rfr, Volatility* vol, Option* opts[], int num) : _spot(spot), _rfr(rfr), _vol(vol) {
			for (int i=0; i < num; i++) _options.push_back(opts[i]);
		}
	};

	class PricingEngine {
	protected:
		int _nt, _ns;
	public:
		PricingEngine() : _nt(0), _ns(0) {}
		PricingEngine(int n) : _nt(n), _ns(n) {}
		PricingEngine(int nx, int ny) : _nt(nx), _ns(ny) {}

		inline int GetNt() const { return _nt; }
		inline int GetNs() const { return _ns; }

		virtual ublas::matrix<double> evaluate(OptionPack& pack) throw(Unsupported) = 0;
		virtual ublas::matrix<double> evaluate(double spot, double rfr, Volatility* vol, Option& option) throw(Unsupported) = 0;
	};

	class IncrementFunctor {
	private:
		double _cur, _step;
		bool _first_step;
	public:
		IncrementFunctor(double cur = 0, double step = 1) : _cur(cur), _step(step), _first_step(true) {}

		double operator() () { 
			if (_first_step) {
				_first_step = false;
				return _cur;
			} else return _cur += _step; 
		}
	};

	class FDM_PricingEngine : public PricingEngine {
	public:
		enum Scheme {
			Implicit,
			Explicit
		};

	private:
		Scheme _scheme;

	public:
		FDM_PricingEngine() : PricingEngine(), _scheme(Implicit) {}
		FDM_PricingEngine(int n) : PricingEngine(n), _scheme(Implicit) {}
		FDM_PricingEngine(int nx, int ny) : PricingEngine(nx, ny), _scheme(Implicit) {}
		FDM_PricingEngine(Scheme scheme) : PricingEngine(), _scheme(scheme) {}
		FDM_PricingEngine(Scheme scheme, int n) : PricingEngine(n), _scheme(scheme) {}
		FDM_PricingEngine(Scheme scheme, int nx, int ny) : PricingEngine(nx, ny), _scheme(scheme) {}

		virtual ublas::matrix<double> evaluate(OptionPack& pack) {
			return ublas::zero_matrix<double>(_nt, _ns);
		};

		virtual ublas::matrix<double> evaluate(double spot, double rfr, Volatility* vol, Option& option) throw(Unsupported) {
			using namespace boost::lambda;

			double strike = option.GetStrike();
			double term = option.GetTerm();
			double minVol, maxVol;
			double dT;
			bool uncertain;

			// todo European / American

			if (ConstantVolatility* cVol = dynamic_cast<ConstantVolatility*>(vol)) {
				minVol = maxVol = cVol->volatility();
				uncertain = false;
			} else if (UncertainVolatility* uVol = dynamic_cast<UncertainVolatility*>(vol)) {
				minVol = uVol->GetMinVol();
				maxVol = uVol->GetMaxVol();
				uncertain = true;
			} else {
				throw new Unsupported("Unknown type of volatility");
			}

			if (_scheme == Explicit) {
				dT = 0.9 / SQR(maxVol/100) / SQR(_ns);
				_nt = std::ceil(term / dT); 
			}
			dT = term / (_nt - 1);

			ublas::vector<double> j(_ns-1), S(_ns-1);
			ublas::matrix<double> V = ublas::zero_matrix<double>(_ns, _nt);

			IncrementFunctor step; 
			std::generate(j.begin(), j.end(), step);
			
			IncrementFunctor inc_dT(0, dT);
			std::generate(S.begin(), S.end(), inc_dT);

			//std::for_each(S.begin(), S.end(), std::cout << _1 << " ");
			//std::cout << "\n";

			return V;
		};
	};
}

using namespace boost::numeric;
using namespace Options;

int main() {
	DigitalOption o1(30, Option::Call, 1.0);
	VanillaOption o2(30, Option::Put, 1.5);
	ConstantVolatility vol(0.1);
	double rfr = 0.05;

	Option* arr[] = {&o1, &o2};
	OptionPack pack(25.0, rfr, &vol, arr, 2);

	FDM_PricingEngine engine(10);

	try {
		ublas::matrix<double> res = engine.evaluate(25.0, rfr, &vol, o1);
		std::cout << res.size1() << " " << res.size2();
	} catch (OptionException* e) {
		std::cout << "Wrong!; " << e->Message();
	}

	_getch();

	return 0;
}