clear variables
close all

import optima.*
import optima.test.*

TOL = 1e-5;

func = @(x) sqrt(sum(x.*x));
[val, point] = Optimize(func, [1 1 1]);
assert((Dist(val,0) < TOL) && (Dist(point, [0 0 0]') < TOL), 'Failed to converge on spheroid');

func = @(x) optima.test.Rosenbrock(x);
[val, point] = Optimize(func, [-1 5 2]);
assert((Dist(val,0) < TOL) && (Dist(point, [1 1 1]') < TOL), 'Failed to converge on Rosenbrock function');

func = @(x) optima.test.Beale(x(1), x(2));
[val, point] = Optimize(func, [0 0], 1);
assert((Dist(val,0) < TOL) && (Dist(point, [3 0.5]') < TOL), 'Failed to converge on Beale function');


fprintf('Test successful\n');