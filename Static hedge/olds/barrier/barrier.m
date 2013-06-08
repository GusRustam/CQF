%% Cleanup
clear all
close all
clc

%% Basic grid characteristics
pointsS = 40;

%% Option parameters
Strike = 10;
Term = 5;
Spot = 2;
Barrier = 12;
BarrierType = 'In';
DividendYield = 0;
Rebate = 0.1;
RFR = 5;
Sigma = 20;
Type = 'Put';

nT = 50;

[V_a, Val_a] = analytical(Type, BarrierType, ...
                          Strike, Spot, Barrier, ...
                          Rebate, Term, Sigma, RFR, DividendYield, ...
                          pointsS, nT);

%dV = V_a - V_i;
%dV1 = V_a - V_e;
%dV2 = V_i - V_e;