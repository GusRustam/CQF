function [ v, surface ] = VanillaBS( Option, Asset, RFR, Grid  )
%VANILLABS Vanilla option Black-Scholes price
    import enums.*
    
    Strike = Option.Strike;
    Term = Option.Term;
    Spot = Asset.Spot;
    Sigma = Asset.Vol;

    if Option.Kind ~= OptionKind.Vanilla 
        throw(MException('VanillaBS:InvalidOperation', ...
                         'VanillaBS function is applicable only to vanilla options'));
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
        
    s = Sigma/100;
    r = RFR/100;

    if nargin < 4
        % User specified no grid, hence we'll give him price only
        if Term > 0 
            d1 = (log(Spot/Strike) + (r+s^2/2)*Term)/(s*sqrt(Term));
            d2 = d1 - s*sqrt(Option.Term);
            v = P*normcdf(P*d1)*Spot + (-P)*normcdf(P*d2)*Strike*exp(-r*Term);
        else
            v = max(P*(Spot-Strike),0);
        end
    elseif Term > 0
        % user asks for the whole payoff surface
        max_spot = 2 * Strike;
        
        num_spots = Grid(1);   % spots are in rows
        num_terms = Grid(2);   % terms are in columns
        
        SpotGrid = (0:(max_spot/(num_spots-1)):max_spot)'; % first dimension 
        TermGrid = Term:(-Term/(num_terms-1)):0; % second dimension
        
        term1 = repmat(log(SpotGrid/Strike),[1 num_terms]);
        term2 = repmat((r+s^2/2)*TermGrid,[num_spots 1]);
        term3 = repmat(s*sqrt(TermGrid),[num_spots 1]);
        
        d1 = (term1 + term2)./term3;
        d2 = d1 - term3;
        
        t1 = repmat(SpotGrid,[1 num_terms]).*normcdf(P*d1); %repmat(SpotGrid,[1 num_terms]).
        t2 = Strike*repmat(exp(-r*TermGrid),[num_spots 1]).*normcdf(P*d2);
        surface = P*(t1 - t2);
 
        v = interp1(SpotGrid, surface(:,1)', Spot);       
    else
        % user asks only for payoff profile
        max_spot = 2 * Strike;
        num_spots = Grid(1);   % spots are in rows
        SpotGrid = (0:(max_spot/(num_spots-1)):max_spot)'; % first dimension 
        surface = P*(SpotGrid - Strike);
        surface(P*(SpotGrid - Strike <= 0)) = 0;

        v = 0;
    end
end

