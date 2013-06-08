function [x,fval,exitflag,output,lambda,grad,hessian] = test(x0,lb,ub)
%% This is an auto generated MATLAB file from Optimization Tool.

%% Start with the default options
options = optimset;
%% Modify options setting
options = optimset(options,'Display', 'off');
options = optimset(options,'FunValCheck', 'off');
options = optimset(options,'Algorithm', 'interior-point');
[x,fval,exitflag,output,lambda,grad,hessian] = ...
fmincon(@(params)vasicek_cost_function(params,spot_rates/100,terms),x0,[],[],[],[],lb,ub,[],options);