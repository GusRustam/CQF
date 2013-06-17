function [ p ] = PackPrice( Pack, Scheme, Grid, Vol, BS )
%PACKPRICE Calculates price of residual option
%   Pack - the package with options. First option is main option and others
%   are used for optimization purposes
%
%   Scheme - Implicit or Explcit
%
%   Grid - optional parameter; grid of 100 x 100is used when not specified
%   First element is number of asset steps and the second is number of time
%   steps. Second element will be overridden if Explicit scheme is used.
%
%   BS - optional parameter, determines how to price secondary options; if 
%   not specified or zero I use FDM, else Black and Scholes

    %% Imports
    import enums.*
    import pricing.*

    global trace;

    %% Parameters
    if nargin < 5
        BS = 0;
    end

    if nargin < 4
        Grid = [100 100];
    end

    %% First I find price of the whole package
    [p, ~, numK] = PriceOptionPack(Pack, Scheme, Grid(1), Grid(2));

    % 
    A = Pack.Asset;
    A.Vol = Vol;
    A.VolatilityModel = VolatilityModel.Constant;

    %% Next I subtract price of each bond except for the main one
    for i=2:length(Pack.Options)
        if BS ~= 0 
            p = p - PriceOptionBS(Pack.Options(i), A, Pack.RFR);
    else
            p = p - PriceOption(Pack.Options(i), A, Pack.RFR, Scheme, Grid(1), numK);
        end
    end
    trace(end,end) = p;
end

