classdef VanillaOption < pack.options.OptionBase
    methods
        %% Payoff function
        function p = Payoff(~, Price)
            if Type == OptionType.Call
                p = max(Strike-Price, 0);
            else
                p = max(Price-Strike, 0);
            end
        end
        
        %% Single option price
        function v = Value(obj, Spot, Vol, RFR)
            v = SingleOptionValue(obj, Spot, Vol, RFR);
        end
        
        %% Constructor
        function obj = VanillaOption(Term, Type, Strike)
            obj = obj@pack.options.OptionBase(Term, Type, Strike);
        end
    end
end