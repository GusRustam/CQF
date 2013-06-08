function [ beta,gamma,etha ] = vasicek_fit( rates, terms )
    params = 0.2*ones(1,3);
    options = optimset('GradObj','on');
    costFunction = @(params) vasicek_cost_function(params,rates,terms);
    params = fmincon(costFunction, params, [], [], [], [], [0 0 0], [10 10 10], [], options);

    beta = params(1);
    gamma = params(2);
    etha = params(3);
end

