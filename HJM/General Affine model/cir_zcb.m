function [ zcb ] = cir_zcb( params, r0, T )
    [A,B] = cir_ab(params, T);
    zcb = exp(A-B*r0);
end

