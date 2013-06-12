function [ r ] = Dist(x, y)
%DIST Summary of this function goes here
%   Detailed explanation goes here
    r = sqrt(sum((x-y).^2));
end

