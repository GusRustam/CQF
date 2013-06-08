%% Cleanup
clear all
close all
clc

%% Basic grid characteristics
pointsS = 30;

%% Option parameters
Strike = 10;
Term = 5;
Spot = 8;
RFR = 5;
Sigma = 20;
Type = 'Call';
tic
[V_e, Val_e, nT] = vanilla_e(Type, Strike, Spot, Term, Sigma, RFR, pointsS);
toc                                                                                                                                         
tic
[V_i, Val_i] = vanilla_i(Type, Strike, Spot, Term, Sigma, RFR, pointsS, nT);
toc
tic
[V_i2, Val_i2] = vanilla_i2(Type, Strike, Spot, Term, Sigma, RFR, pointsS, nT);
toc
tic
[V_a, Val_a] = vanilla_a(Type, Strike, Spot, Term, Sigma, RFR, pointsS, nT);
toc
dV = V_a - V_i;
dV1 = V_a - V_e;
dV2 = V_i - V_e;

vanilla_price_a(Type, Strike, Spot, Term, Sigma, RFR)