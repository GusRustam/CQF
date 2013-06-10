function [ val, point ] = Optimize( func, initial_guess, delta )
%OPTIMIZE Downhill simplex method
    %% Checking params
    if (nargin < 3) delta = sum(inital_guess.^2)/10; end; %#ok
    if (nargin < 2) throw('Optimize:Initial guess is madatory'); end; %#ok
    
    %% Preparation
    % transposing initial guess so that it was column vector
    % like that: [a b c d]'
    if (size(initial_guess,1) < size(initial_guess,2)) 
        initial_guess = initial_guess';
    end
    % numer of dimensions in question
    num_dims = length(initial_guess);
    num_vals = num_dims + 1;
    
    simplex = repmat(initial_guess, [1 num_vals]);
    % first column of simplex is out inital vector and others are 
    % initial_guess shifted by delta at each of coordinates
    simplex(:, 2:num_dims+1) = simplex(:, 2:num_dims+1) + eye(num_dims)*delta;
    
    % Now it looks like (let x = delta)
    %
    % | a  a + x    a      a      a   |
    % | b    b    b + x    b      b   |
    % | c    c      c    c + x    c   | 
    % | d    d      d      d    d + x |
    
    % y represents function value on simplex vertices
    y = zeros(num_vals, 1);
    
    % calculating y
    for i = 1:num_vals
        y(i) = fund(simplex(:, i));
    end
    
    % vec_sum represents row vector with sum of simplex vectors along
    % columns, it is used when we reflect the simplex
    vec_sum = sum(simplex, 1);
    
    while 1
        lpi = 0;  % lowest point index
        hpi = 0;  % highest point index
        nhpi = 0; % next highest point index
        
        % init highest point search
        if y(2) > y(1)
            hpi = 2;
            nhpi = 1;
        else
            hpi = 1;
            nhpi = 2;
        end
        
        % searching
        for i = 1:num_vals
            if (y(i) < y(lpi)) lpi = i; end;
            if (y(i) > y(hpi)) 
                nhpi = hpi;
                hpi = i; 
            elseif (y(i) > y(nhpi))
                nhpi = i;
            end
        end
    end
end

