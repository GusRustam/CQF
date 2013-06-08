function [ zcb ] = vasicek_zcb( params, r0, T )
    beta = params(1);
    gamma = params(2);
    etha = params(3);
    B = (1 - exp(-gamma * T)) / gamma;
    A = (B - T) / (gamma ^ 2) * (etha * gamma - beta / 2) - beta * (B ^ 2) / (4 * gamma);
%    [A,B] = vasicek_ab(params, T);
    zcb = exp(A-B*r0);
end

