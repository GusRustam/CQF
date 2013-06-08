function [ V, Val ] = implicit(Type, Strike, Spot, Term, Sigma, RFR, N, K)
    %% Grid parameters
    maxS = 2*Strike;
    dS = maxS/(N-1);
    dT = Term/(K-1);
    S = 0:dS:maxS;
    j = 0:(N-1);
    
    %% Boundary conditions (european call option)
    V = zeros(N, K);

    % Lower boundary (S = 0): V = 0; it's already set. todo more exact
    % cond's
    
    % Upper boundary (S = maxS): dynamic V(Si,Tk) = 2*V(Si-1,Tk)-V(Si-2,Tk)
    % and will be calculated during iterations
    
    % Right boundary (T = Term): V(Si, T) = max(Si - Strike, 0)
    if strcmpi(Type, 'CALL')
        V(:, K) = max(S-Strike, zeros(1:N-1,1));
    else
        V(:, K) = max(Strike-S, zeros(1:N-1,1));
    end

    %% Calculating option value on the grid
    s = Sigma/100;
    r = RFR/100;
    
    a = 0.5 * (s*j).^2 * dT;
    b = 0.5 * r*j * dT;
    c = -r * dT;

    A = -a + b;
    B = 1 + 2*a - c;
    C = -a - b;

    Z = diag(C(2:N-2),1) + diag(B(2:N-1)) + diag(A(3:N-1),-1);
    if strcmpi(Type, 'CALL')
        Z(N-2,N-2) = B(N-1)+2*C(N-1);
        Z(N-2,N-3) = A(N-1)-C(N-1);
    else
        Z(1,1) = B(2)+2*A(1);
        Z(1,2) = C(2)-A(2);
    end
    
    for k=K:-1:2
        V(2:N-1,k-1) = Z\V(2:N-1,k);
    end
    if strcmpi(Type, 'CALL')
        V(N,:) = 2*V(N-1,:)-V(N-2,:);
    else
        V(1,:) = 2*V(2,:)-V(3,:);
    end
    
    %% Direct computation 
    
    % Approximately 6 times faster on 250x350 grid, but 2 times slower on
    % 25x35 grid
    
    %tic
    %Zk = inv(Z)^(K-1);
    %V1 = zeros(N, 1);
    %V1(2:N-1) = Zk*V(2:N-1,K);
    %V1(N) = 2*V1(N-1) - V1(N-2);
    %toc
    
    %V = V1;
    
    %% Result
    Val = interp1(S, V(:,1)', Spot);
end

