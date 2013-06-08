%% Cleanup
clear all
close all
clc

%% Basic grid characteristics
pointsS = 25;

%% Option parameters
Strike = 10;
Term = 5;
Spot = 5;
Barrier = 8;
BarrierType = 'Out';
DividendYield = 0;
Rebate = 0;
RFR = 5;
Sigma = 20;
Type = 'Put';

nT = 45;

[V_a, Val_a] = barrier_a(Type, BarrierType, ...
                          Strike, Spot, Barrier, ...
                          Rebate, Term, Sigma, RFR, DividendYield, ...
                          pointsS, nT);
                      
[V_e, Val_e] = barrier_e(Type, BarrierType, ...
                          Strike, Spot, Barrier, ...
                          Rebate, Term, Sigma, RFR, DividendYield, ...
                          pointsS);

%dV = V_a - V_i;
%dV1 = V_a - V_e;
%dV2 = V_i - V_e;