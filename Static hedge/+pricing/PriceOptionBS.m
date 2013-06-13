function [ v, surface ] = PriceOptionBS( Option, Asset, RFR, Grid )
    import enums.*
    import pricing.*
    import pricing.blackscholes.*
    
    if Option.Kind == OptionKind.Digital 
       [ v, surface ] = DigitalBS(Option, Asset, RFR, Grid);
   elseif Option.Kind == OptionKind.Vanilla
       [ v, surface ] = VanillaBS(Option, Asset, RFR, Grid);
   else
       throw(MException('PriceOptionBS:InvalidOperation', ...
                 'PriceOptionBS function is applicable only to digital and vanilla options'));
   end
end
