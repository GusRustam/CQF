%% General setup
clear variables

import enums.*
import pricing.*
import pricing.blackscholes.*

Pack.Options(1).Kind = OptionKind.Digital;
Pack.Options(1).Type = OptionType.Call;
Pack.Options(1).Strike = 11;
Pack.Options(1).Term = 1;
Pack.Options(1).Amount = -1;

Pack.Options(2).Kind = OptionKind.Vanilla;
Pack.Options(2).Type = OptionType.Call;
Pack.Options(2).Strike = 11;
Pack.Options(2).Term = 1;
Pack.Options(2).Amount = 1;

Pack.Asset.Spot = 9;

Pack.RFR = 7;

Method = FDMScheme.Implicit;

%% Test 1. Uncertain volatilty yields price higher than certain
Pack.Asset.Vol = 20;
Pack.Asset.VolatilityModel = VolatilityModel.Constant;
[certain_p1, certain_v1] = PriceOption(Pack.Options(1), Pack.Asset, Pack.RFR, Method, 100, 200);
[certain_p2, certain_v2] = PriceOption(Pack.Options(2), Pack.Asset, Pack.RFR, Method, 100, 200);

Pack.Asset.Vol = [20 30];
Pack.Asset.VolatilityModel = VolatilityModel.Uncertain;
[uncertain_p1, uncertain_v1] = PriceOption(Pack.Options(1), Pack.Asset, Pack.RFR, Method, 100, 200);
[uncertain_p2, uncertain_v2] = PriceOption(Pack.Options(2), Pack.Asset, Pack.RFR, Method, 100, 200);

plotdiff(certain_v1, uncertain_v1);
pause
plotdiff(certain_v2, uncertain_v2);
pause
close all

assert(certain_p1 < uncertain_p1, 'Certain vol price is higher than uncertain!');
assert(certain_p2 < uncertain_p2, 'Certain vol price is higher than uncertain!');

%% Test 2. Pack is cheaper than two separate options (both certain and unceritain)
Pack.Asset.Vol = 20;
Pack.Asset.VolatilityModel = VolatilityModel.Constant;
[certain_pack_p, certain_pack_v] = PriceOptionPack(Pack, Method, 100, 200);
assert(abs(certain_p1+certain_p2-certain_pack_p)<1e-3, 'Certain pack not equal to separate!');
plotdiff(certain_pack_v, certain_v1 + certain_v2);
pause
close all

Pack.Asset.Vol = [20 30];
Pack.Asset.VolatilityModel = VolatilityModel.Uncertain;
[uncertain_pack_p, uncertain_pack_v] = PriceOptionPack(Pack, Method, 100, 200);
assert(uncertain_p1+uncertain_p2 > uncertain_pack_p, 'Uncertain pack cheaper than separate!');
plotdiff(uncertain_pack_v, uncertain_v1 + uncertain_v2);
pause
close all

%% Finalization
fprintf('All tests passed successfully\n');

