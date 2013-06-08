function [ V, Val ] = vanilla_a(Type, Strike, Spot, Term, Sigma, RFR, pointsS, pointsT)
    %% Grid parameters
    N = pointsS;
    K = pointsT;
    
    maxS = 2*Strike;
    dS = maxS/(N-1);
    dT = Term/(K-1);
    S = 0:dS:maxS;
    T = 0:dT:Term;

    s = Sigma/100;
    r = RFR/100;

    V = zeros(N, K);
    P = 2*strcmpi(Type, 'Call')  - 1; % Yes -> 1; No -> -1

    for i = 1:N
        for j = 1:K-1
            d1 = (log(S(i)/Strike) + (r+s^2/2)*(Term-T(j)))/(s*sqrt(Term-T(j)));
            d2 = d1 - s*sqrt(Term-T(j));
            V(i,j) = P*normcdf(P*d1)*S(i) + (-P)*normcdf(P*d2)*Strike*exp(-r*(Term-T(j)));
        end
        V(i,K) = vanilla_payoff(P, Strike, S(i));
    end
       
    %% Result
    Val = interp1(S, V(:,1)', Spot);
end