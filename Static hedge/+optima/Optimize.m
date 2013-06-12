function [ val, point ] = Optimize( func, initial_guess, delta, tolerance, max_calc )
%OPTIMIZE Downhill simplex method
    import optima.*
    
    %% Checking params
    if (nargin < 5) max_calc = 5000; end; %#ok
    if (nargin < 4) tolerance = 1e-4; end; %#ok
    if (nargin < 3) delta = sum(initial_guess.^2)/10; end; %#ok
    if (nargin < 2) throw(MException('Optimize:InvalidOperation','Initial guess is madatory'); end; %#ok
    
    % Checking if initial guess is ok
    if ismatrix(initial_guess) 
        if size(initial_guess,1) ~= 1 && size(initial_guess,2) ~= 1
            throw(MException('Optimize:InvalidOperation',':Inital guess must be a vector'));
        end
    else
        throw(MException('Optimize:InvalidOperation',':Inital guess must be a vector'));
    end
    
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
    
    %-------------------------------------------------------
    % Now it looks like (let x = delta)
    %-------------------------------------------------------
    %
    % | a  a + x    a      a      a   |
    % | b    b    b + x    b      b   |
    % | c    c      c    c + x    c   | 
    % | d    d      d      d    d + x |
    %
    %-------------------------------------------------------
    %
    % here number of rows is number of dimensions
    % and number of columns is number of vectors in simplex
    % second must be first + 1
    %
    %-------------------------------------------------------
    
    % y represents function value on simplex vertices
    y = zeros(num_vals, 1);
    
    % calculating y
    for i = 1:num_vals
        y(i) = func(simplex(:, i));
    end
    
    % calculating sum by columns
    row_sum = sum(simplex, 2);
    
    % counting iterations
    num_calc = 0;
    
    %% Main cycle
    while 1
        lpi = 1;  % lowest point index
        
        % init highest point search
        if y(2) > y(1)
            hpi = 2;    % highest point index
            nhpi = 1;   % next highest point index
        else
            hpi = 1;
            nhpi = 2;
        end
        
        % searching for lowest, highest and next to highest points
        for i = 1:num_vals
            if (y(i) < y(lpi)) lpi = i; end; %#ok
            if y(i) > y(hpi)
                nhpi = hpi;
                hpi = i; 
            elseif y(i) > y(nhpi) && i ~= hpi
                nhpi = i;
            end
        end
        
        % checking exit condition
        tol = 2*abs(y(hpi)-y(lpi))/(abs(y(hpi))+abs(y(lpi))+1e-10);
        if tol < tolerance 
            % if satisfied, returning value and lowest point
            val = y(lpi);
            point = simplex(:, lpi);
            return
        end
        
        % checking overflow condition
        if num_calc >= max_calc
            throw(MException('Optimization:Overflow','Exceeded max number of iterations'));
        end
        num_calc = num_calc + 2;
        
        % first we reflect the simplex and see if something's got better
        [test_val, y, row_sum, simplex] = TryExtrapolate(simplex, y, row_sum, hpi, -1, func);
        if test_val <= y(lpi)
            % yes, it got better. Thus we'll try to strech simplex twice (p.s
            % TryExtrapolate won't do anything unless it was really helpful)
            [~, y, row_sum, simplex] = TryExtrapolate(simplex, y, row_sum, hpi, 2, func);
        elseif test_val >= y(nhpi)
            % nope, it wouldn't get better
            last_high = y(hpi);
            % let's try to contract the simplex
            [test_val, y, row_sum, simplex] = TryExtrapolate(simplex, y, row_sum, hpi, 0.5, func);
            if test_val >= last_high
                % it didn't help too. Then we will try to contract around
                % the best point
                for i=1:num_vals
                    if i ~= lpi
                        simplex(:,i) = 0.5*(simplex(:,i)+simplex(:,lpi));
                        y(i) = func(sum(simplex(i)));
                    end
                end
                num_calc = num_calc + num_vals;
                row_sum = sum(simplex, 2);
            end
        else
            num_calc = num_calc - 1;
        end
    end
end

