function [price, surface] = PriceOption(Option, Asset, RFR, Scheme, N)
    Spot = Asset.Spot;
    VolModel = Asset.VolatilityModel;
    Sigma = Asset.Volatility;
    
    Strike = Option.Strike;
    Term = Option.Term;
    Type = Option.Type;
    Kind = Option.Kind;
    
    if (nargin < 5) N = 30; end; %#ok
    if (nargin < 4) Scheme = FDMScheme.Explicit; end; %#ok

    %% Grid parameters
    maxS = 2*Strike;
    dS = maxS / (N - 1);
    
    if Scheme == FDMScheme.Implicit
        K = N;
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
    if Type == OptionType.Call
       its_call = 1; 
    else
       its_call = -1;
    end
    if Kind == OptionKind.Digital
        V(its_call*(S-Strike)>0, K) = 1;
    elseif Kind == OptionKind.Vanilla
        V(:, K) = max(its_call*(S-Strike)', zeros(N,1));
    else
        throw(['PriceOption:Unsupported option kind ' OptionKind]);
    end
        
    %% Calculating option value on the grid
    if VolModel == VolatilityModel.Constant
        s = Sigma/100;
        r = RFR/100;
        a = 0.5 * (s*j).^2  * dT;
        b = 0.5 * r * j * dT; 
        c = -r * dT;

        if Scheme == FDMScheme.Implicit
            A = -a + b;
            B = 1 + 2*a - c;
            C = -a - b;
        else
            A = a - b;
            B = 1 - 2*a + c; 
            C = a + b;
        end

        Z = diag(C(2:N-2),1) + diag(B(2:N-1)) + diag(A(3:N-1),-1);
        if Type == OptionType.Call
            Z(N-2,N-2) = B(N-1)+2*C(N-1);
            Z(N-2,N-3) = A(N-1)-C(N-1);
        else
            Z(1,1) = B(2)+2*A(1);
            Z(1,2) = C(2)-A(2);
        end

        if Scheme == FDMScheme.Implicit
            for k=K:-1:2
                V(2:N-1, k-1) = Z\V(2:N-1,k);
            end
        else
            for k=K:-1:2
                V(2:N-1, k-1) = Z*V(2:N-1,k);
            end
        end
        
        if Type == OptionType.Call
            V(N,:) = 2*V(N-1,:)-V(N-2,:);
        else
            V(1,:) = 2*V(2,:)-V(3,:);
        end
    elseif VolModel == VolatilityModel.Uncertain
        s_min = min(Sigma)/100;
        s_max = max(Sigma)/100;
        r = RFR/100;
        
        a_min = 0.5 * (s_min*j).^2  * dT;
        a_max = 0.5 * (s_max*j).^2  * dT;
        b = 0.5 * r * j * dT; 
        c = -r * dT;

        if Scheme == FDMScheme.Implicit
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
        if Type == OptionType.Call
            Z_min(N-2,N-2) = B_min(N-1)+2*C_min(N-1);
            Z_min(N-2,N-3) = A_min(N-1)-C_min(N-1);
            Z_max(N-2,N-2) = B_max(N-1)+2*C_max(N-1);
            Z_max(N-2,N-3) = A_max(N-1)-C_max(N-1);
        else
            Z_min(1,1) = B_min(2)+2*A_min(1);
            Z_min(1,2) = C_min(2)-A_min(2);
            Z_max(1,1) = B_max(2)+2*A_max(1);
            Z_max(1,2) = C_max(2)-A_max(2);
        end

        for k=K:-1:2
            Gamma = diff(diff(V(:,k)));
            GammaNeg = Gamma <= 0;
            Z = Z_min;
            Z(GammaNeg, :) = Z_max(GammaNeg, :);
            if Scheme == FDMScheme.Implicit > 0
                V(2:N-1, k-1) = Z\V(2:N-1,k);
            else
                V(2:N-1, k-1) = Z*V(2:N-1,k);
            end
            if Type == OptionType.Call
                V(N,k-1) = 2*V(N-1,k)-V(N-2,k);
            else
                V(1,k-1) = 2*V(2,k)-V(3,k);
            end
        end
    else
        throw(['PriceOption:Unsupported volatility model ' VolModel]);
    end
    
    surface = V;
    price = interp1(S, V(:,1)', Spot);
end

