function [ A,B ] = cir_ab( params, T )
    alpha = params(1);
    gamma = params(2);
    etha = params(3);
    beta = 0;

    psy1 = sqrt(gamma^2+2*alpha);
    b = (gamma+psy1)/alpha;
    a = (-gamma+psy1)/alpha;
    psy2 = (etha - a*beta/2)/(a + b);
    epsy1 = exp(psy1*T);
    B = 2*(epsy1-1) / ((gamma + psy1)*(epsy1-1) + 2*psy1);
    A = (2/alpha) * (a*psy2*log(a-B) + (psy2+beta/2)*b*log((B+b)/b) - beta*B/2 - a*psy2*log(a));
end