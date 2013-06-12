function [ v, surface ] = DigitalBS( Option, Asset, RFR, Grid )
%DIGITALBS Digital cash-or-nothing Black-Scholes price
    import enums.*
    
    Strike = Option.Strike;
    Term = Option.Term;
    Spot = Asset.Spot;
    Sigma = Asset.Vol;

    if Option.Kind ~= OptionKind.Digital 
        throw(MException('DigitalBS:InvalidOperation', ...
                         'DigitalBS function is applicable only to digital options'));
    end

    if Asset.VolatilityModel ~= VolatilityModel.Constant
        throw(MException('VanillaBS:InvalidOperation', ...
                         'VanillaBS function is applicable only to constant volatility model'));
    end

    if Option.Type == OptionType.Call 
        P = 1;
    else
        P = -1;
    end
    
    if nargin < 4
        if Term > 0 
            s = Sigma/100;
            r = RFR/100;
            d1 = (log(Spot/Strike) + (r+s^2/2)*Term)/(s*sqrt(Term));
            d2 = d1 - s*sqrt(Option.Term);
            v = exp(-r*Term)*normcdf(P*d2);
        else
            if P*(Strike-Spot) > 0
                v = 1;
            else
                v = 0;
            end
        end
        surface = 0;
    elseif Term > 0
        % user asks for the whole payoff surface
        max_spot = 2 * Strike;
        
        num_spots = Grid(1);   % spots are in rows
        num_terms = Grid(2);   % terms are in columns
        
        SpotGrid = (0:(max_spot/(num_spots-1)):max_spot)'; % first dimension 
        TermGrid = Term:(-Term/(num_terms-1)):0; % second dimension
        
        s = Sigma/100;
        r = RFR/100;
        
        term1 = repmat(log(SpotGrid/Strike),[1 num_terms]);
        term2 = repmat((r-s^2/2)*TermGrid,[num_spots 1]);
        term3 = repmat(s*sqrt(TermGrid),[num_spots 1]);
        
        d = (term1 + term2)./term3;
              
        surface = repmat(exp(-r*TermGrid),[num_spots 1]) .* normcdf(P*d);
        tmp = surface(:,end);
        
        tmp(P*(SpotGrid - Strike)>0) = 1;
        tmp(P*(SpotGrid - Strike)<=0) = 0;
        surface(:,end) = tmp;
        v = interp1(SpotGrid, surface(:,1)', Spot);       
    else
        % user asks only for payoff profile
    end


end

