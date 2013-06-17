function [ beta,gamma,etha ] = fit_general_affine_model( rates, terms, model )
    params = ones(1,3);
    if strcmpi(model,'Vasicek')
        costFunction = @(params) affine_cost_function(params,rates,terms,@vasicek_yield);
        params = fmincon(costFunction, params, [], [], [], [], [0 0 -Inf], [100 Inf Inf]);
    elseif strcmpi(model,'CIR')
        costFunction = @(params) affine_cost_function(params,rates,terms,@cir_yield);
        params = fmincon(costFunction, params, [], [], [], [], [0 0 0], [Inf Inf Inf]);
    end

    beta = params(1);
    gamma = params(2);
    etha = params(3);
end

