using System;
using System.Diagnostics;
using System.Windows.Forms;

namespace TrinomialTree {
    public partial class MainForm : Form {
        public MainForm() {
            InitializeComponent();
        }

        private void CalculateClick(object sender, EventArgs e) {
// ReSharper disable ObjectCreationAsStatement
            new BinomialTree(
// ReSharper restore ObjectCreationAsStatement
                new[] {0.0608, 0.0611, 0.0621, 0.0631, 0.0655}, 
                new[] {0.00, 0.17, 0.16, 0.15, 0.13});
        }
    }

    public interface ISolver {
        double? Solve(Func<double, double> what, double from, double to);
    }

    public class Solver : ISolver {
        public double? Solve(Func<double, double> what, double from, double to) {
            Debug.Assert(Math.Sign(what(from))!= Math.Sign(what(to)), "Function must be of different signs on borders");
            do {
                var mid = (to + from)/2;
                var valOnTo = what(to);
                var valOnMid = what(mid);
                if (Math.Sign(valOnTo) != Math.Sign(valOnMid)) 
                    from = mid;
                else to = mid;
            } while (Math.Abs(from-to) > 10e-5);
            return (to + from) / 2;
        }
    }

    public class BinomialTree {
        private readonly double[] _treeRates;
        private readonly double[] _treeTerms;
        private readonly double[] _treeVols;
        private readonly int _n;

        public BinomialTree(double[] rates, double[] vols, double[] terms = null) {
            Debug.Assert(rates.Length == vols.Length, "Count of rates and volatilities must be equal");

            _n = rates.Length;
            _treeRates = new double[_n];
            _treeVols = vols;
            if (terms != null) {
                Debug.Assert(terms.Length == vols.Length, "Count of rates and volatilities must be equal");
                _treeTerms = terms;
            } else {
                _treeTerms = new double[_n];
                for (var i = 0; i < _n; i++) _treeTerms[i] = i+1;
            }
            _treeRates[0] = rates[0];

            ISolver solver = new Solver();
            for (var i = 1; i < _n; i++) {
                // 1) calculating price of ZCB with term i and rate r[i]
                var price = Math.Exp(-rates[i]*_treeTerms[i]);
                // 2) finding rate which would make bond price equal to calculated price
                var num = i;
                var rt = solver.Solve(rate => EvaluatePrice(rate, num+1) - price, 0.00, 1.00);
                if (rt == null) throw new InvalidOperationException("Didn't converge!");
                _treeRates[i] = rt.Value;
            }
        }

        private double EvaluatePrice(double rate, int num) {
            var oldPrices = new double[num + 1];
            var newPrices = new double[num];
            for (var i = 0; i < num + 1; i++) oldPrices[i] = 1;

            for (var n = num-1; n >= 0; n--) {
                for (var k = 0; k <= n; k++) {
                    var rt = ((n == num - 1) ? rate : _treeRates[n]) * Math.Exp(-2 * _treeVols[n] * k);
                    newPrices[n - k] = 0.5*(oldPrices[n-k] + oldPrices[n-k+1])*Math.Exp(-rt);
                }
                if (n > 0) for (var k = 0; k <= n; k++) oldPrices[k] = newPrices[k];
            }
            return newPrices[0];
        }
    }

    //public enum BranchingMode {
    //    Up, Mid, Down
    //}

    //public class TrinomialTreeNode {
    //    private int _i, _j;
    //    private double _rate;
    //    private readonly double _pu, _pd, _pm;
    //    private TrinomialTreeNode _parent, _u, _d, _m;
    //    private readonly TrinomialTree _model;

    //    public TrinomialTreeNode(int i, int j, double rate, TrinomialTreeNode parent, TrinomialTree model) {
    //        _i = i;
    //        _j = j;
    //        _rate = rate;
    //        _parent = parent;
    //        _model = model;
            
    //        var a = model.MeanReversion;
    //        var dt = model.TimeStep;
    //        var ajdt = a * j * dt;

    //        var mode = Math.Abs(j) < _model.Threshold ? BranchingMode.Mid : (a > 0 ? BranchingMode.Up : BranchingMode.Down);
    //        switch (mode) {
    //            case BranchingMode.Up:
    //                _pu = 1/6 + ajdt*(ajdt + 1)/2;
    //                _pm = -1/3 - ajdt*(ajdt + 2);
    //                _pd = 7/6 + ajdt*(ajdt + 3)/2;
    //                break;
    //            case BranchingMode.Mid:
    //                _pu = 1/6 + ajdt*(ajdt - 1)/2;
    //                _pm = 2/3 - ajdt*ajdt;
    //                _pd = 1/6 + ajdt*(ajdt + 1)/2;
    //                break;
    //            case BranchingMode.Down:
    //                _pu = 7/6 + ajdt * (ajdt - 3)/2;
    //                _pm = -1/3 - ajdt * (ajdt - 2);
    //                _pd = 1/6 + ajdt*(ajdt - 1)/2;
    //                break;
    //            default:
    //                throw new ArgumentOutOfRangeException("Invalid mode");
    //        }

    //        Debug.Assert(Math.Abs(_pu+_pm+_pd-1)<1e-3, "Probabilities don't sum up into 1");
    //        Debug.Assert(_pu > 0 && _pm > 0 && _pd > 0, "Negative probabilities");
    //    }
    //}

    //public class TrinomialTree {
    //    private readonly double _a;
    //    private readonly double _dt;
    //    private readonly double _n;
    //    private readonly double _sigma;
    //    private readonly Func<double, double> _theta;
    //    private readonly TrinomialTreeNode _head;
    //    private readonly int _threshold;

    //    public int Threshold {
    //        get { return _threshold; }
    //    }

    //    public double MeanReversion {
    //        get { return _a; }
    //    }

    //    public double TimeStep {
    //        get { return _dt; }
    //    }

    //    public TrinomialTree(double a, double dt, double sigma, double n, Func<double, double> theta) {
    //        _a = a;
    //        _sigma = sigma;
    //        _theta = theta;
    //        _n = n;
    //        _dt = dt;
    //        _threshold = (int) (a > 0 ? Math.Ceiling(0.184/(_a*_dt)) : Math.Floor(-0.184/(_a*_dt)));
    //        _head = new TrinomialTreeNode(0, 0, 0, null, this);
    //    }
    //}
}
