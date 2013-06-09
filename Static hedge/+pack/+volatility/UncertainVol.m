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
        
        function vol = Vol(obj)
            vol = [obj.xVolMin, obj.xVolMax];
        end
    end
end