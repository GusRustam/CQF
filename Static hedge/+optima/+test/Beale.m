function [ v ] = Beale( x ,y )
%BEALE Summary of this function goes here
%   Detailed explanation goes here
    v = (1.5-x+x*y)^2 + (2.25-x+x*y^2)^2+(2.625-x+x*y^3)^2;
end

