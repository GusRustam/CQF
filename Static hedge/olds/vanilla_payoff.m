function [ payoff ] = vanilla_payoff( P, Strike, Spot )
%VANILLA_PAYOFF Summary of this function goes here
%   Detailed explanation goes here
    if length(Strike) == 1 && length(Spot) == 1
        zero = 0;
    elseif length(Strike) > 1 && length(Spot) == 1
        zero = zeros(size(Strike,1), size(Strike,2));
    elseif length(Strike) == 1 && length(Spot) > 1
        zero = zeros(size(Spot,1), size(Spot,2));
    elseif length(Strike) == length(Spot) 
        zero = zeros(size(Spot,1), size(Spot,2));
    else
        error('Strike and Spot must be of same size or only one of the could be a vector');
    end
    payoff = max(P*(Spot - Strike), zero);
end

