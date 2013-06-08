function [ yield ] = vasicek_yield( params, r0, T )
    yield = -log(vasicek_zcb(params,r0,T))/T;
end