function [price, surface, numK] = PriceOptionPack(OptionPack, Scheme, N, K)
    Spot = OptionPack.Asset.Spot;
    VolModel = OptionPack.Asset.VolatilityModel;
    Sigma = OptionPack.Asset.Vol;
    RFR = OptionPack.RFR;   
    NumOptions = length(OptionPack.Options);
    
    Terms = zeros(1, NumOptions);
    Kinds = cell(1, NumOptions);
    Strikes = zeros(1, NumOptions);
    ItsCalls = zeros(1, NumOptions);
    
    for i = 1:NumOptions
        Terms(i) = OptionPack.Options(i).Term;
        Kinds{i} = OptionPack.Options(i).Kind;
        Strikes(i) = OptionPack.Options(i).Strike;
        if strcmpi(OptionPack.Options(i).Type, 'CALL')
            ItsCalls(i) = 1; 
        else
            ItsCalls(i) = -1;
        end
    end
    
    Term = max(Terms);
    
    if nargin < 3
        N = 30;
    end
    
    if nargin < 2
        Scheme = 'Explicit';
    end
    
    if strcmpi(Scheme, 'Implicit')
        implicit = 1;
    else
        implicit = -1;
    end
      
    %% Grid parameters
    maxS = 2*max(Strikes);
    dS = maxS / (N - 1);
    
    if strcmpi(Scheme, 'Implicit')
        if nargin < 4
            K = N;
        end            
    else
        dT = 0.9 / ((max(Sigma)/100)^2) / (N^2);
        K = ceil(Term / dT);
    end
    dT = Term / (K-1);

    S = 0:dS:maxS;    
    j = 0:N-1;
    %% Boundary conditions (european call option)
    V = zeros(N, K);

    % Lower boundary (S = 0): V = 0; it's already set
    % Upper boundary (S = maxS): non-static: V(Si,Tk) = 2*V(Si-1,Tk)-V(Si-2,Tk)
    % and will be calculated during iterations
    % Right boundary (T = Term): V(Si, T) = max(Si - Strike, 0)
    for i=1:NumOptions
        tau = min(floor(Terms(i) / dT)+1, K);
%         if tau > K
%             tau = K;
%         end
        if strcmpi(Kinds{i}, 'DIGITAL')
            V(ItsCalls(i)*(S-Strikes(i))>0, tau) = V(ItsCalls(i)*(S-Strikes(i))>0, tau) + 1;
        elseif strcmpi(Kinds{i}, 'VANILLA')
            V(:, tau) = V(:, tau) + max(ItsCalls(i)*(S-Strikes(i))', zeros(N,1));
        end
    end
    
    while sum(V(:, end)) == 0
        V = V(:, 1:end-1);
        K = K - 1;
    end

    %% Calculating option value on the grid
    if strcmpi(VolModel, 'CONST')
        s = Sigma/100;
        r = RFR/100;
        a = 0.5 * (s*j).^2  * dT;
        b = 0.5 * r * j * dT; 
        c = -r * dT;

        if strcmpi(Scheme, 'Implicit')
            A = -a + b;
            B = 1 + 2*a - c;
            C = -a - b;
        else
            A = a - b;
            B = 1 - 2*a + c; 
            C = a + b;
        end

        Z = diag(C(2:N-2),1) + diag(B(2:N-1)) + diag(A(3:N-1),-1);
        %if strcmpi(Type, 'CALL')
            Z(N-2,N-2) = B(N-1)+2*C(N-1);
            Z(N-2,N-3) = A(N-1)-C(N-1);
        %else
            Z(1,1) = B(2)+2*A(1);
            Z(1,2) = C(2)-A(2);
        %end

        if strcmpi(Scheme, 'Implicit')
            for k=K:-1:2
                V(2:N-1, k-1) = V(2:N-1, k-1) + Z\V(2:N-1,k);
            end
        else
            for k=K:-1:2
                V(2:N-1, k-1) = V(2:N-1, k-1) + Z*V(2:N-1,k);
            end
        end
        
        %if strcmpi(Type, 'CALL')
            V(N,:) = 2*V(N-1,:)-V(N-2,:);
        %else
            V(1,:) = 2*V(2,:)-V(3,:);
        %end
    elseif strcmpi(VolModel, 'UNCERTAIN')
        s_min = min(Sigma)/100;
        s_max = max(Sigma)/100;
        r = RFR/100;
        
        a_min = 0.5 * (s_min*j).^2  * dT;
        a_max = 0.5 * (s_max*j).^2  * dT;
        b = 0.5 * r * j * dT; 
        c = -r * dT;

        if strcmpi(Scheme, 'Implicit')
            A_min = -a_min + b;
            B_min = 1 + 2*a_min - c; 
            C_min = -a_min - b;

            A_max = -a_max + b;
            B_max = 1 + 2*a_max - c; 
            C_max = -a_max - b;
        else
            A_min = a_min - b;
            B_min = 1 - 2*a_min + c; 
            C_min = a_min + b;

            A_max = a_max - b;
            B_max = 1 - 2*a_max + c; 
            C_max = a_max + b;
        end

        Z_min = diag(C_min(2:N-2),1) + diag(B_min(2:N-1)) + diag(A_min(3:N-1),-1);
        Z_max = diag(C_max(2:N-2),1) + diag(B_max(2:N-1)) + diag(A_max(3:N-1),-1);
        %if strcmpi(Type, 'CALL')
            Z_min(N-2,N-2) = B_min(N-1)+2*C_min(N-1);
            Z_min(N-2,N-3) = A_min(N-1)-C_min(N-1);
            Z_max(N-2,N-2) = B_max(N-1)+2*C_max(N-1);
            Z_max(N-2,N-3) = A_max(N-1)-C_max(N-1);
        %else
            Z_min(1,1) = B_min(2)+2*A_min(1);
            Z_min(1,2) = C_min(2)-A_min(2);
            Z_max(1,1) = B_max(2)+2*A_max(1);
            Z_max(1,2) = C_max(2)-A_max(2);
        %end

        for k=K:-1:2
            Gamma = diff(diff(V(:,k)));
            GammaNeg = Gamma <= 0;
            Z = Z_min;
            Z(GammaNeg, :) = Z_max(GammaNeg, :);
            if implicit > 0
                V(2:N-1, k-1) = V(2:N-1, k-1) + Z\V(2:N-1,k);
            else
                V(2:N-1, k-1) = V(2:N-1, k-1) +  Z*V(2:N-1,k);
            end
            %if its_call > 0
                V(N,k-1) = 2*V(N-1,k)-V(N-2,k);
            %else
                V(1,k-1) = 2*V(2,k)-V(3,k);
           % end
        end
    end
    
    surface = V;
    price = interp1(S, V(:,1)', Spot);
    numK = K;
end

