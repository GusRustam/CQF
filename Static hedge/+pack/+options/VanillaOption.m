classdef VanillaOption < pack.options.OptionBase
    methods
        function p = Payoff(Price)
            if Type == OptionType.Call
                p = max(Strike-Price, 0);
            else
                p = max(Price-Strike, 0);
            end
        end
                
        function obj = VanillaOption(Term, Type, Strike)
            obj = obj@pack.options.OptionBase(Term, Type, Strike);
        end
    end
end