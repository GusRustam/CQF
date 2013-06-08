classdef (Abstract) OptionBase
    %OPTION Simple abstract option
    %   Provides simple option description
    %   - term (time in years)
    %   - type (put/call)
    %   - strike price
    
    properties
        Term
        Type
        Strike
    end
    
    methods(Abstract)
        Payoff(Price)
    end
    
    methods
        function obj = OptionBase(Term, Type, Strike)
            obj.Term = Term;
            obj.Type = Type;
            obj.Strike = Strike;
        end
    end
end

