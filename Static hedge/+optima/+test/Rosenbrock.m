function [ y ] = Rosenbrock( x )
%ROSENBROCK Summary of this function goes here
    y = 0;
    for i=1:length(x)-1
        y = y + 100*(x(i+1)-x(i)^2)^2+(x(i)-1)^2;
    end
end

