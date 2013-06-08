function [ yield ] = cir_yield( params, r0, T )
    yield = -log(cir_zcb(params,r0,T))/T;
end