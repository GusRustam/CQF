classdef DigitalOption < pack.options.OptionBase
    methods
        %% Payoff function
        function p = Payoff(~, Price)
            if Type == OptionType.Call
                if Strike >= Price
                    p = 1;
                else
                    p = 0;
                end
            else
                if Strike >= Price
                    p = 0;
                else
                    p = 1;
                end
            end
        end
        
         %% Single option price
        function v = Value(obj, Spot, Vol, RFR)
            v = SingleOptionValue(obj, Spot, Vol, RFR);
        end
        
        %% Constructor
        function obj = DigitalOption(Term, Type, Strike)
            obj = obj@pack.options.OptionBase(Term, Type, Strike);
        end
    end
end