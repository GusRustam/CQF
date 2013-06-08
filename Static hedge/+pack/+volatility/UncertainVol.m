classdef UncertainVol < pack.volatility.Volatility
    properties(Access=private)
        xVolMin
        xVolMax
    end
    
    methods
        function obj = UncertainVol(VolMin, VolMax)
            obj.xVolMin = VolMin;
            obj.xVolMax = VolMax;
        end
        
        function vol = Vol(obj, Gamma)
            if Gamma >= 0
                vol = obj.xVolMin;
            else
                vol = obj.xVolMax;
            end
        end
    end
end