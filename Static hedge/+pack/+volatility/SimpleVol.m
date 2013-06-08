classdef SimpleVol < Volatility
    properties(Access=private)
        xVol 
    end
    
    methods
        function obj = SimpleVol(Vol)
            obj.xVol = Vol;
        end
        
        function vol = Vol(obj, ~)
            vol = obj.xVol;
        end
    end
end