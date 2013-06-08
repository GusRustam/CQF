function [X] = polynom(theX, N)
    % N - power of polynomial
    K = size(theX, 1);  % number of rows
    X = ones(K, N+1);   % K x N+1 matrix of theX powers
    
    for i = 1:N
        X(:,i+1) = theX.^i;
    end
end