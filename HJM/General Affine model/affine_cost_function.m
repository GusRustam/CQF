function [ c ] = affine_cost_function( params, rates, terms, affine_yield )
    c = 0;
    for i = 1:length(terms)
        x = affine_yield(params, rates(1), terms(i));
        c = c + (rates(i) - x)^2;
    end
end

