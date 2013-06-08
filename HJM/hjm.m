%% Cleanup and data loading
clc;
clear all;
close all;

%% Setting up constants
Q = 12;                 % number of compoundings per year for non-infinitesimal model
N = 3;                  % number of principal components
M = 10;                 % number of simulations
D = 252;                % days in year
T = 5*D;                % number of days to simulate
dT = 1/D;               % time step for simulation
s_dT = sqrt(dT);

MICEX_NSS = 1;
BANK_ENGLAND_FWD = 2;
SELECTED_MODEL = BANK_ENGLAND_FWD;

LOGNORMAL = 1;          % 0 - standard model, 1 - non-infinitesimal
APPROXIMATE = 1;        % 0 - no principal components approximation, 1 - polynomial approximation
QUASY_RANDOM = 1;       % 0 - use quasi-random, 1 - low-discrepancy numbers

%% Loading data
switch SELECTED_MODEL
    case MICEX_NSS
        % I have to load data and calculate three variables: dates, rates, terms
        load('hjm_micex_nss.mat');
        terms = [0.01 0.5:0.5:25];
        d_terms = diff(terms);
        
        N1 = size(BETA0, 1);
        M1 = size(terms, 2);
        rates = zeros(N1, M1);
        
        for i = 1:N1
            tau_t = TAU(i)./terms;
            t_tau = terms./TAU(i);
            e_tau_t = exp(-t_tau);
            rates(i,:) = BETA0(i) ...
                        + (BETA1(i)+BETA2(i))*tau_t.*(1-e_tau_t) ...
                        - BETA2(i)*e_tau_t ... 
                        + G1(i)*exp(-(terms.^2)/2) ...
                        + G2(i)*exp(-((terms-1).^2)/2) ...
                        + G3(i)*exp(-((terms-2).^2)/2);
            rates(i,:) = rates(i,:) / 100;
            d_rates = diff(rates(i,:));
            rates(i,:) = convert_to_forward(rates(i,:), terms); 
        end
        dates = TRADEDATE;
    case BANK_ENGLAND_FWD
        load('hjm_boe_forward.mat');
        d_terms = diff(terms);
end

%% Removing empty data
index = find(min(rates, [], 2) == 0);    % finding rows which contain zeros
report.num_zeros = size(index, 1);

rates(index, :) = [];
dates(index) = [];

dates = x2mdate(dates); % not really necessary but nice indeed

%% Estimating volatilities of interest rates
if LOGNORMAL == 0 
    covariance = cov(diff(rates)) * D/10000;
else
    covariance = cov(diff(((1+rates).^(1/Q)-1)*Q)) * D/10000;
end

[V,K] = eig(covariance);
eigen_values = diag(K);
report.percentage_explained = sum(eigen_values(end-N+1:end))/sum(eigen_values);
eigen_values = eigen_values(end-N+1:end);
eigen_vectors = V(:, end-N+1:end);
for i=1:N
    eigen_vectors(:,i) = eigen_vectors(:,i).*sqrt(eigen_values(i));
end

%% And plotting eigenvectors
plot(terms, eigen_vectors, 'YDataSource', 'eigen_vectors', 'XDataSource', 'terms');

%% Fitting eigenvectors
X = polynom(terms', 3);
theta = pinv(X'*X) * X' * eigen_vectors;
fitted_eigen_vectors = X*theta;

%% And plotting eigenvectors together with fitted eigenvectors
plot(terms,[eigen_vectors fitted_eigen_vectors], 'YDataSource', 'eigen_vectors', 'XDataSource', 'terms');

%% Estimating risk-neutral drift and volatility
if APPROXIMATE == 0
    pcv = eigen_vectors;
else
    pcv = fitted_eigen_vectors;
end
N1 = size(pcv, 1);
M1 = size(pcv, 2);

diffusion = zeros(N1, M1);
diffusion(1,:) = pcv(1,:);
for i = 2:N1
    % TODO here's numerical integration while I could do exact
    diffusion(i,:) = diffusion(i-1,:)+((pcv(i,:)+pcv(i-1,:))/2)*d_terms(i-1); 
end

pcv = pcv .* diffusion;
drift = sum(pcv, 2);

%% And plotting drift
plot(terms, drift, 'YDataSource', 'drift_vector', 'XDataSource', 'terms');

%% Monte-Carlo simulation using Musiela parametrization
% At the moment I have a current forward rate curve
[~, index] = max(dates);    % select last date
F0 = rates(index, :)/100;   % initial rate curve

% Defining Zero-Coupon Bond
ZCB.Term = 5;
ZCB.Data = zeros(1,M); % a zero-coupon bond with maturity of 5 years

% Defininig Cap
Cap.Term = 4;
Cap.Rate = (2/3)*mean(mean(rates))/100;
Cap.Period = 1/4;
Cap.Caplets = zeros(M, Cap.Term/Cap.Period);
Cap.Periods = floor(cumsum(ones(1,Cap.Term/Cap.Period)*Cap.Period)*D);
Cap.NumPmts = Cap.Term/Cap.Period;

tic
dt = [d_terms d_terms(end)];

for time=1:M
    M = size(terms, 2);
    f = zeros(T, M);
    f(1,:) = F0;
    if QUASY_RANDOM == 0 
        motion =  randn(T, N) * diffusion';
    else
        rands = zeros(T,N);
        for i = 1:N
            rands(:,i) = lhsnorm(0,1,T)';
        end
        motion = rands * diffusion';
    end
    for i = 2:T
        df = diff(f(i-1,:));
        df = [df df(end)] ./ dt;
        if LOGNORMAL > 0 
            f(i,:) = f(i-1,:) + (drift' + df) * dT + Q*(1-exp(f(i-1,:)/Q)) .* motion(i,:) * s_dT; 
        else
            f(i,:) = f(i-1,:) + (drift' + df) * dT + motion(i,:) * s_dT; 
        end
    end
    % TODO: ':' works when term of bond is equal to depth of simulation 
    ZCB.Data(time) = exp(-sum(f(:,1))*dT); 

    % Using terms array determine which terms are the closest to
    % selected Cap.Period and approximate forward curve at that point using
    % linear interpolation. I also have to remember that this is a FORWARD
    % curve while I need a SPOT one. And, finally, i have to DISCOUNT
    % caplets payoff so that to obatin PV.
    % taking yield curves at preselected (cap payoff dates). 
    curves = f(Cap.Periods, :); 
    % converting into spot rates
    for n = 1:Cap.NumPmts
        forward_rates = curves(n,:);
        curves(n,:) = convert_to_spot(forward_rates, terms);
    end
    % obtaining current rate using interpolation
    currentRates = interp1(terms, curves', Cap.Term);
    % calculating payoffs 
    Cap.Caplets(time, :) = max(currentRates-Cap.Rate.*ones(1,Cap.NumPmts),zeros(1,Cap.NumPmts));
    
    % discounting
    discount_curve = f(1,:);
    discount_curve = [discount_curve(1) (cumsum(discount_curve(2:end).*diff(terms))+discount_curve(1)*terms(1))./terms(2:end)];
    discount_factors = zeros(1, Cap.NumPmts);
    for n = 1:Cap.NumPmts
        discount_factors(n) = interp1(terms, discount_curve, Cap.Periods(n)/D);
    end
    
    discount_factors = exp(-discount_factors.*Cap.Periods/D);
    Cap.Caplets(time, :) = Cap.Caplets(time, :).*discount_factors;   
end

toc
ZCB.Price = mean(ZCB.Data);
ZCB.Yield = -1/(T/D)*log(ZCB.Price)*100;
Cap.Price = sum(sum(Cap.Caplets))/size(Cap.Caplets,1)/size(Cap.Caplets,2);

%% And plotting curvez
mesh(f); figure(gcf);