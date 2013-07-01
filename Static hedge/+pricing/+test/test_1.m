%% General setup
clear variables

import enums.*
import pricing.*
import pricing.blackscholes.*
import pricing.test.*

Pack.Options(1).Kind = OptionKind.Digital;
Pack.Options(1).Type = OptionType.Call;
Pack.Options(1).Strike = 11;
Pack.Options(1).Term = 1;
Pack.Options(1).Amount = 1;

Pack.Asset.Spot = 9;
Pack.RFR = 7;

Method = FDMScheme.Implicit;

%% Test 1. Uncertain vol-ty is more costly than certain (digital)
Pack.Asset.Vol = 15;
Pack.Asset.VolatilityModel = VolatilityModel.Constant;
[~, certain_min] = PriceOption(Pack.Options(1), Pack.Asset, Pack.RFR, Method, 100, 200);
certain_min = certain_min(:,1);

Pack.Asset.Vol = 30; 
Pack.Asset.VolatilityModel = VolatilityModel.Constant;
[~, certain_max] = PriceOption(Pack.Options(1), Pack.Asset, Pack.RFR, Method, 100, 200);
certain_max = certain_max(:,1);

Pack.Asset.Vol = [15 30];
Pack.Asset.VolatilityModel = VolatilityModel.Uncertain;
[~, uncertain] = PriceOption(Pack.Options(1), Pack.Asset, Pack.RFR, Method, 100, 200);
uncertain = uncertain(:,1);

plotXXX([certain_min, certain_max, uncertain]);
pause
close all

%% Test 2. Uncertain vol-ty is more costly than certain (vanilla)
Pack.Options(1).Kind = OptionKind.Vanilla;

Pack.Asset.Vol = 15;
Pack.Asset.VolatilityModel = VolatilityModel.Constant;
[~, certain_min] = PriceOption(Pack.Options(1), Pack.Asset, Pack.RFR, Method, 100, 200);
certain_min = certain_min(:,1);

Pack.Asset.Vol = 30;
Pack.Asset.VolatilityModel = VolatilityModel.Constant;
[~, certain_max] = PriceOption(Pack.Options(1), Pack.Asset, Pack.RFR, Method, 100, 200);
certain_max = certain_max(:,1);

Pack.Asset.Vol = [15 30];
Pack.Asset.VolatilityModel = VolatilityModel.Uncertain;
[~, uncertain] = PriceOption(Pack.Options(1), Pack.Asset, Pack.RFR, Method, 100, 200);
uncertain = uncertain(:,1);

plotXXX([certain_min, certain_max, uncertain]);
pause
close all

clear variables
clear imports