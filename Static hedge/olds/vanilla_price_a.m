function [ v ] = vanilla_price_a(Type, Strike, Spot, Term, Sigma, RFR)
    P = 2*strcmpi(Type, 'Call')  - 1; % Yes -> 1; No -> -1
    if Term > 0 
        s = Sigma/100;
        r = RFR/100;
        d1 = (log(Spot/Strike) + (r+s^2/2)*Term)/(s*sqrt(Term));
        d2 = d1 - s*sqrt(Term);
        v = P*normcdf(P*d1)*Spot + (-P)*normcdf(P*d2)*Strike*exp(-r*Term);
    else
        v = vanilla_payoff(P, Strike, Spot);
    end
end

