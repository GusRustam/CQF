%% Cleanup
clear all
close all
clc

%% Basic grid characteristics
pointsS = 50;

%% Option parameters
Strike = 10;
Term = 5;
Spot = 8;
RFR = 5;
Sigma = 20;
Type = 'Put';
tic
[V_e, Val_e, nT] = explicit(Type, Strike, Spot, Term, Sigma, RFR, pointsS);
toc                                                                                                                                         
tic
[V_i, Val_i] = implicit(Type, Strike, Spot, Term, Sigma, RFR, pointsS, nT);
toc
tic
[V_i2, Val_i2] = implicit2(Type, Strike, Spot, Term, Sigma, RFR, pointsS, nT);
toc
tic
[V_a, Val_a] = analytical(Type, Strike, Spot, Term, Sigma, RFR, pointsS, nT);
toc
dV = V_a - V_i;
dV1 = V_a - V_e;
dV2 = V_i - V_e;