classdef (Abstract) Option
    %OPTION Simple abstract
    %   Provides simple option description
    properties
        Term
        Type
        Strike
    end
    
    methods(Abstract)
        Payoff(Price)
    end
    
    methods
        function obj = Option(Term, Type, Strike)
            obj.Term = Term;
            obj.Type = Type;
            obj.Strike = Strike;
        end
    end
    
end

