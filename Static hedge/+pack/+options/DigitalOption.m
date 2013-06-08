classdef DigitalOption < Option
    methods
        function p = Payoff(Price)
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
        
        function obj = DigitalOption(Term, Type, Strike)
            obj = obj@Option(Term, Type, Strike);
        end
    end
end