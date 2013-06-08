function [ V, Val, K ] = barrier_e(Type, BarrierType, Strike, Spot, Barrier, Rebate, Term, Sigma, RFR, DividendYield, N)
    P = 2*strcmpi(Type, 'Call')  - 1; % Yes -> 1; No -> -1
    if Spot < Barrier               % Up and %BarrierType%  %Type%
        %% Grid parameters
        maxS = Barrier;
        minS = 0;
        dS = (maxS - minS) / (N - 1);
        S = minS:dS:maxS;    
        dT = 0.9 / ((Sigma/100)^2) / (N^2);
        K = ceil(Term / dT);
        dT = Term / (K-1);
        V = zeros(N, K);
        
        %% Boundary conditions
        if strcmpi(BarrierType, 'In')               % up and in %Type%
            % Boundary conditions are:
            %    1) by spot at upper barrier - black-sholes price of corresponding vanilla
            for j=1:K
                V(N,j) = vanilla_price_a(Type, Strike, S(N), Term - j*dT, Sigma, RFR-DividendYield);
            end
            %    2) by spot at 0 - 0
            % already done
            %    3) by time: at end of time (T) - rebate
            V(:,K) = Rebate;
        else                                        % up and out %Type%
            % Boundary conditions are:
            %    1) by spot at upper barrier - rebate
            V(N,:) = Rebate;
            %    2) by spot at 0 - 0
            % already done
            %    3) by time: at end of time (T) - payoff of corresponding vanilla
            V(:,K) = vanilla_payoff(P, S, Strike);
        end

        %% Calculating option value on the grid
        j = 0:N-1;  

        s = Sigma/100;
        r = (RFR - DividendYield)/100; % todo is this correct?
        a = 0.5 * (s*j).^2  * dT;
        b = 0.5 * r * j * dT; 
        c = -r * dT;

        A = a - b;
        B = 1 - 2*a + c; 
        C = a + b;

        Z = diag(C(2:N-2),1) + diag(B(2:N-1)) + diag(A(3:N-1),-1);

        for k=K:-1:2
            V(2:N-1, k-1) = Z*V(2:N-1,k);
        end
        Val = interp1(S, V(:,1)', Spot); 
    else                % Down and %BarrierType% %Type%
        %% Grid parameters
        maxS = 2*Strike;
        minS = Barrier;
        dS = (maxS - minS) / (N - 1);
        S = minS:dS:maxS;    
        dT = 0.9 / ((Sigma/100)^2) / (N^2);
        K = ceil(Term / dT);
        dT = Term / (K-1);
        V = zeros(N, K);

        if strcmpi(BarrierType, 'In')             % down and in %Type%
            % Boundary conditions are:
            %   1) by spot at upper bound - linear interpolation
            % todo during iterations <-------------- !!!
            %   2) by spot at lower barrier - black-sholes price of corresponding vanilla
            for j=1:K
                V(1,j) = vanilla_price_a(Type, Strike, S(1), Term - j*dT, Sigma, RFR-DividendYield);
            end
            %   3) by time at end of time (T) - rebate 
            V(:,K) = Rebate;
        else                                      % down and out %Type%
            % Boundary conditions are:
            %    1) by spot at upper bound - linear interpolation
            % todo during iterations <-------------- !!!
            %    2) by spot at lower barrier - rebate 
            V(1,:) = Rebate;
            %    3) by time at end of time (T) - payoff of corresponding vanilla
            V(:,K) = vanilla_payoff(P, S, Strike);
       end
        %% Calculating option value on the grid
        j = 0:N-1;  
        s = Sigma/100;
        r = (RFR - DividendYield)/100; % todo is this correct?
        a = 0.5 * (s*j).^2  * dT;
        b = 0.5 * r * j * dT; 
        c = -r * dT;

        A = a - b;
        B = 1 - 2*a + c; 
        C = a + b;

        Z = diag(C(2:N-2),1) + diag(B(2:N-1)) + diag(A(3:N-1),-1);
        
        Z(N-2,N-2) = B(N-1)+2*C(N-1);
        Z(N-2,N-3) = A(N-1)-C(N-1);
        
        for k=K:-1:2
            V(2:N-1, k-1) = Z*V(2:N-1,k);
        end
        
        V(N,:) = 2*V(N-1,:)-V(N-2,:);
        Val = interp1(S, V(:,1)', Spot); 
    end
end

