function [ V, Val, K ] = explicit(Type, BarrierType, Strike, Spot, Barrier, Rebate, Term, Sigma, RFR, DividendYield, N)

    %% Notes
    % Explicit Euler scheme for european call option. Second order of
    % accuracy by both T and S. Limited convergence.
    
    % V - full price surface
    % Val - value for certain spot
    % pointsT - number of points by time

    %% Grid parameters
    maxS = 2*Strike;
    dS = maxS / (N - 1);
    
    dT = 0.9 / ((Sigma/100)^2) / (N^2);
    K = ceil(Term / dT);
    dT = Term / (K-1);

    S = 0:dS:maxS;    
    j = 0:N-1;  

    %% Boundary conditions (european call option)
    V = zeros(N, K);
    
    if Spot < Barrier
        % up and %BarrierType%  %Type%
        if strcmpi(BarrierType, 'In') 
            % up and in %Type%
            
            % boundary conditions are:
            % by spot: 
            % at upper barrier - black-sholes price of corresponding vanilla
            % at 0 - 0
            % by time: at end of time (T) - rebate 
        else
            % up and out %Type%
 
            % boundary conditions are:
            % by spot: 
            % at upper barrier - rebate
            % at 0 - 0
            % by time: at end of time (T) - payoff of corresponding vanilla
        end
    else
        % down and %BarrierType% %Type%
        if strcmpi(BarrierType, 'In') 
            % down and in %Type%
            
            % boundary conditions are:
            % by spot: 
            % at upper bound - linear interpolation
            % at lower barrier - black-sholes price of corresponding vanilla 
            % by time: at end of time (T) - rebate 

        else
            % down and out %Type%
            
            % boundary conditions are:
            % by spot: 
            % at upper bound - linear interpolation
            % at lower barrier - rebate 
            % by time: at end of time (T) - payoff of corresponding vanilla
       end
    end
    
    if strcmpi(Type, 'CALL')
        V(:, K) = max(S-Strike, zeros(1:N-1,1));
    else
        V(:, K) = max(Strike-S, zeros(1:N-1,1));
    end

    % Lower boundary (S = 0): V = 0; it's already set
    % Upper boundary (S = maxS): non-static: V(Si,Tk) = 2*V(Si-1,Tk)-V(Si-2,Tk)
    % and will be calculated during iterations
    % Right boundary (T = Term): V(Si, T) = max(Si - Strike, 0)

    %% Calculating option value on the grid
    s = Sigma/100;
    r = (RFR - DividendYield)/100; % todo is this correct?
    a = 0.5 * (s*j).^2  * dT;
    b = 0.5 * r * j * dT; 
    c = -r * dT;

    A = a - b;
    B = 1 - 2*a + c; 
    C = a + b;
    
    Z = diag(C(2:N-2),1) + diag(B(2:N-1)) + diag(A(3:N-1),-1);
    if strcmpi(Type, 'CALL')
        Z(N-2,N-2) = B(N-1)+2*C(N-1);
        Z(N-2,N-3) = A(N-1)-C(N-1);
    else
        Z(1,1) = B(2)+2*A(1);
        Z(1,2) = C(2)-A(2);
    end
    Z = sparse(Z);
 
    for k=K:-1:2
        V(2:N-1, k-1) = Z*V(2:N-1,k);
    end
    if strcmpi(Type, 'CALL')
        V(N,:) = 2*V(N-1,:)-V(N-2,:);
    else
        V(1,:) = 2*V(2,:)-V(3,:);
    end

    Val = interp1(S, V(:,1)', Spot);
end

