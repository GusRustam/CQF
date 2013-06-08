function [ V, Val ] = barrier_a(Type, BarrierType, Strike, Spot, Barrier, Rebate, Term, Sigma, RFR, DividendYield, pointsS, pointsT)
    %% Grid parameters
    V = zeros(pointsS, pointsT);
    
    maxS = 2*Strike;
    dS = maxS/(pointsS-1);
    dT = Term/(pointsT-1);
    S = 0:dS:maxS;
    T = 0:dT:Term;
    
    s = Sigma/100;
    r = RFR/100;
    b = DividendYield/100;
   
    mu = (b-s^2/2)/s^2;
    lambda = sqrt(mu^2 + 2*r/s^2);
    
    x1 = @(S,X,T) log(S/X)/(s*sqrt(T)) + (1+mu)*s*sqrt(T);
    x2 = @(S,H,T) log(S/H)/(s*sqrt(T)) + (1+mu)*(s*sqrt(T));
    y1 = @(S,H,X,T) log((H^2)/(S*X))/(s*sqrt(T)) + (1+mu)*(s*sqrt(T));
    y2 = @(S,H,T) log(H/S)/(s*sqrt(T)) + (1+mu)*(s*sqrt(T));  
    z  = @(S,H,T) log(H/S)/(s*sqrt(T)) + lambda*(s*sqrt(T));
    
    N = @(x) normcdf(x);
    
    A = @(Phi,Etha,S,X,H,K,T)   ...
        Phi*S*exp((b-r)*T)*N(Phi*x1(S,X,T)) - ...
        Phi*X*exp(-r*T)*N(Phi*x1(S,X,T)-Phi*s*sqrt(T));
    B = @(Phi,Etha,S,X,H,K,T)   ...
        Phi*S*exp((b-r)*T)*N(Phi*x2(S,H,T)) - ...
        Phi*X*exp(-r*T)*N(Phi*x2(S,H,T) - Phi*s*sqrt(T));
    C = @(Phi,Etha,S,X,H,K,T)   ...
        Phi*S*exp((b-r)*T)*((H/S)^(2*(mu+1)))*N(Etha*y1(S,H,X,T)) - ...
        Phi*X*exp(-r*T)*((H/S)^(2*mu))*N(Etha*y1(S,H,X,T)-Etha*s*sqrt(T));
    D = @(Phi,Etha,S,X,H,K,T)    ...
        Phi*S*exp((b-r)*T)*((H/S)^(2*(mu+1)))*N(Etha*y2(S,H,T)) - ...
        Phi*X*exp(-r*T)*((H/S)^(2*mu))*N(Etha*y2(S,H,T)-Etha*s*sqrt(T));
    E = @(Phi,Etha,S,X,H,K,T)   ...
        K*exp(-r*T)*(N(Etha*x2(S,H,T)-Etha*s*sqrt(T)) - ...
                     ((H/S)^(2*mu))*N(Etha*y2(S,H,T)-Etha*s*sqrt(T)));
    F = @(Phi,Etha,S,X,H,K,T)   ...
        K*(((H/S)^(mu+lambda))*N(Etha*z(S,H,T)) - ...
           ((H/S)^(mu-lambda))*N(Etha*z(S,H,T)-2*Etha*lambda*s*sqrt(T)));
                           
     for i = 1:pointsS
        if strcmpi(BarrierType, 'In') 
            % in barrier
            if S(i) ~= Barrier
                % we immediately hit the barrier
                V(i,1) = Rebate;
            else
               % todo - maybe do nonzero at adjacent to barrier points?
               if strcmpi(Type, 'CALL') 
                   V(i,1) = max(S(i) - Strike, 0);
               else
                   V(i,1) = max(Strike - S(i), 0);
               end
            end
        else
            % out barrier
            if strcmpi(Type, 'CALL') 
                V(i,1) = max(S(i) - Strike, 0);
            else
                V(i,1) = max(Strike - S(i), 0);
            end
        end
        
        for j = 2:pointsT
            A1 = @(h,p) A(p,h,S(i),Strike,Barrier,Rebate,T(j));
            B1 = @(h,p) B(p,h,S(i),Strike,Barrier,Rebate,T(j));
            C1 = @(h,p) C(p,h,S(i),Strike,Barrier,Rebate,T(j));
            D1 = @(h,p) D(p,h,S(i),Strike,Barrier,Rebate,T(j));
            E1 = @(h,p) E(p,h,S(i),Strike,Barrier,Rebate,T(j));
            F1 = @(h,p) F(p,h,S(i),Strike,Barrier,Rebate,T(j));
            if S(i) > Barrier 
                % down and %BarrierType% %Type%
                if strcmpi(BarrierType, 'In') 
                    % down and in %Type%
                    if strcmpi(Type, 'CALL')  
                        % down and in call
                        if Strike > Barrier 
                            V(i,j) = C1(1,1)+E1(1,1);
                        else
                            V(i,j) = A1(1,1)-B1(1,1)+D1(1,1)+E1(1,1);
                        end
                    else
                        % down and in put
                        if Strike > Barrier 
                            V(i,j) = B1(1,-1)-C1(1,-1)+D1(1,-1)+E1(1,-1);
                        else
                            V(i,j) = A1(1,-1)+E1(1,-1);
                        end
                    end
                else
                    % down and out %Type%
                    if strcmpi(Type, 'CALL') 
                        % down and out call
                        if Strike > Barrier 
                            V(i,j) = A1(1,1)-C1(1,1)+F1(1,1);
                        else
                            V(i,j) = B1(1,1)-D1(1,1)+F1(1,1);
                        end
                    else
                        % down and out put
                        if Strike > Barrier 
                            V(i,j) = A1(1,-1)-B1(1,-1)+C1(1,-1)-D1(1,-1)+F1(1,-1);
                        else
                            V(i,j) = F1(1,-1);
                        end
                   end
                end
            else
                % up and %BarrierType%
                if strcmpi(BarrierType, 'In') 
                    % up and in %Type%
                    if strcmpi(Type, 'CALL')  
                        % up and in call
                        if Strike > Barrier 
                            V(i,j) = A1(-1,1) + E1(-1,1);
                        else
                            V(i,j) = B1(-1,1) - C1(-1,1) + D1(-1,1) + E1(-1,1);
                        end
                    else
                        % up and in put
                        if Strike > Barrier 
                            V(i,j) = A1(-1,-1) - B1(-1,-1) + D1(-1,-1) + E1(-1,-1);
                        else
                            V(i,j) = C1(-1,-1) + E1(-1,-1);
                        end
                    end
                else
                    % up and out %Type%
                    if strcmpi(Type, 'CALL') 
                        % up and out call
                        if Strike > Barrier 
                            V(i,j) = F1(-1,1);
                        else
                            V(i,j) = A1(-1,1) - B1(-1,1) + C1(-1,1) - D1(-1,1) + F1(-1,1);
                        end
                    else
                        % up and out put
                        if Strike > Barrier
                            V(i,j) = B1(-1,-1) - D1(-1,-1) + F1(-1,-1);
                        else
                            V(i,j) = A1(-1,-1) - C1(-1,-1) + F1(-1,-1);
                        end
                    end
                end
            end
        end

    end
        
    %% Result
    Val = interp1(S, V(:,end)', Spot);
end