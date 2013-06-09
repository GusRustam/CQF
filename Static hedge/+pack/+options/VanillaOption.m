classdef VanillaOption < pack.options.OptionBase
    methods
        %% Payoff function
        function p = Payoff(obj, Price)
            import pack.options.*
            if obj.Type == OptionType.Call
                p = max(obj.Strike-Price, 0);
            else
                p = max(Price-obj.Strike, 0);
            end
        end
        
        %% Single option price
        function v = Value(obj, Spot, Vol, RFR, Method, Size)
            v = pack.options.SingleOptionValue(obj, Spot, Vol, RFR, Method, Size);
        end
        
        %% Constructor
        function obj = VanillaOption(Term, Type, Strike)
            obj = obj@pack.options.OptionBase(Term, Type, Strike);
        end
    end
end