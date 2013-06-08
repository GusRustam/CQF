classdef VanillaOption < Option
    methods
        function p = Payoff(Price)
            if Type == OptionType.Call
                p = max(Strike-Price, 0);
            else
                p = max(Price-Strike, 0);
            end
        end
        
                
        function obj = VanillaOption(Term, Type, Strike)
            obj = obj@Option(Term, Type, Strike);
        end
    end
end