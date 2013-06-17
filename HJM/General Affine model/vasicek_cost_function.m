function [ c, grad ] = vasicek_cost_function( params, rates, terms )
    c = 0;
    for i = 1:length(terms)
        x = vasicek_yield(params, rates(1), terms(i));
        c = c + (rates(i) - x)^2;
    end
    grad = vasicek_grad(params, rates(1), terms(i));
end

