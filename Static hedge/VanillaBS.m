function [ v, surface ] = VanillaBS( Option, Asset, RFR, Grid  )
%VANILLABS Vanilla option Black-Scholes price
    import enums.*
    
    Strike = Option.Strike;
    Term = Option.Term;
    Spot = Asset.Spot;
    Sigma = Asset.Sigma;

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

    if Term > 0 
        s = Sigma/100;
        r = RFR/100;
        d1 = (log(Spot/Strike) + (r+s^2/2)*Term)/(s*sqrt(Term));
        d2 = d1 - s*sqrt(Option.Term);
        v = P*normcdf(P*d1)*Spot + (-P)*normcdf(P*d2)*Strike*exp(-r*Term);
    else
        v = max(P*(Spot-Strike),0);
    end
end

