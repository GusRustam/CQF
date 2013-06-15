function [ v, surface ] = PriceOptionBS(Option, Asset, RFR, Grid)
    import enums.*
    import pricing.*
    import pricing.blackscholes.*
    
    if Option.Kind == OptionKind.Digital
        if nargin < 4
           v = Option.Amount*DigitalBS(Option, Asset, RFR);
        else
           [v, surface] = Option.Amount*DigitalBS(Option, Asset, RFR, Grid);
        end
    elseif Option.Kind == OptionKind.Vanilla
        if nargin < 4
            v = Option.Amount*VanillaBS(Option, Asset, RFR);
        else
            [v, surface] = Option.Amount*VanillaBS(Option, Asset, RFR, Grid);
        end
    else
        throw(MException('PriceOptionBS:InvalidOperation', ...
                 'PriceOptionBS function is applicable only to digital and vanilla options'));
   end
end
