using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Windows.Forms;

namespace TrinomialTree {
    public partial class MainForm : Form {
        public MainForm() {
            InitializeComponent();
        }

        private void CalculateClick(object sender, EventArgs e) {

        }
    }


    public interface ISolver {
        double? Solve(Func<double, double> what, double guess = 0);
    }

    public class Solver : ISolver {
        public double? Solve(Func<double, double> what, double guess = 0) {
            return null;
        }
    }

    public class BinomialTree {
        private readonly double[] _treeRates;
        private readonly double[] _treePrices;
        private readonly double[] _treeVols;
        private readonly int _n;

        // todo another parameter is array of terms
        // todo compounding convertions
        public BinomialTree(double[] rates, double[] vols) {
            Debug.Assert(rates.Length == vols.Length, "Count of rates and volatilities must be equal");

            _n = rates.Length;
            _treeRates = new double[_n];
            _treePrices = new double[_n];
            _treeVols = vols; // ?? copy ok?

            ISolver solver = new Solver();
            for (var i = 1; i < _n; i++) {
                // 1) calculating price of ZCB with term i and rate r[i]
                var price = Math.Exp(-rates[i]*(i+1));
                // 2) finding rate which would make bond price equal to calculated price
                var num = i;
                var rt = solver.Solve(rate => EvaluatePrice(rate, num) - price);
            }
        }

        private double EvaluatePrice(double rate, int nodeNum) {
            // now right-upper node (with index nodeNum) rate is a given rate
            for (var n = nodeNum; n >= 0; n--) {

            }
            return -1;
        }
    }

    public class ArrayTreeItem {
        public double Rate { get; private set; }
        public double Step { get; private set; }

        public ArrayTreeItem(double rate, double step) {
            Rate = rate;
            Step = step;
        }
    }


    public class BinomialTreeNode {
        public double Rate { get; private set; }
        public double Price { get; set; }
        public double Vol { get; private set; }
        public BinomialTreeNode U { get; private set; }
        public BinomialTreeNode D { get; private set; }

        public double EvaluatedPrice(double rate) {
            return -1;
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
