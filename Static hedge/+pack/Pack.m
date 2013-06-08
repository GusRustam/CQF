classdef Pack
    properties
        Options
        Asset
        RFR
    end
    
    methods
        function obj = Pack(Asset, RFR, varargin)
            if isempty(varargin) 
                throw('Pack:No options supplied');
            end
            obj.Asset = Asset;
            obj.RFR = RFR;
            obj.Options = varargin;
        end
    end
end