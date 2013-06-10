clear all
close all

import enums.*

Option.Kind = OptionKind.Digital;
Option.Type = OptionType.Call;
Option.Strike = 10;
Option.Term = 1;

Asset.Spot = 5;
Asset.Vol = 20;
Asset.VolatilityModel = VolatilityModel.Uncertain;

%Engine.Type = 'FDM';
Engine.Method = FDMScheme.Explicit;

RiskFreeRate = 7;

[simpleValue, valueSurface] = PriceOption(Option, Asset, RiskFreeRate, Engine);