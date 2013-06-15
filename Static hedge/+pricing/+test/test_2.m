%% General setup
clear variables

import enums.*
import pricing.*
import pricing.blackscholes.*

Pack.Options(1).Kind = OptionKind.Digital;
Pack.Options(1).Type = OptionType.Call;
Pack.Options(1).Strike = 11;
Pack.Options(1).Term = 1;

Pack.Asset.Spot = 9;
Pack.RFR = 7;

Method = FDMScheme.Implicit;

%% Positive amount
Pack.Options(1).Amount = 1;

Pack.Asset.Vol = 15;
Pack.Asset.VolatilityModel = VolatilityModel.Constant;
[p_min_pos, ~] = PriceOption(Pack.Options(1), Pack.Asset, Pack.RFR, Method, 100, 200);

Pack.Asset.Vol = 30;
Pack.Asset.VolatilityModel = VolatilityModel.Constant;
[p_max_pos, ~] = PriceOption(Pack.Options(1), Pack.Asset, Pack.RFR, Method, 100, 200);

Pack.Asset.Vol = [15 30];
Pack.Asset.VolatilityModel = VolatilityModel.Uncertain;
[p_unc_pos, ~] = PriceOption(Pack.Options(1), Pack.Asset, Pack.RFR, Method, 100, 200);


%% Negative amount
Pack.Options(1).Amount = -1;

Pack.Asset.Vol = 15;
Pack.Asset.VolatilityModel = VolatilityModel.Constant;
[p_min_neg, ~] = PriceOption(Pack.Options(1), Pack.Asset, Pack.RFR, Method, 100, 200);

Pack.Asset.Vol = 30;
Pack.Asset.VolatilityModel = VolatilityModel.Constant;
[p_max_neg, ~] = PriceOption(Pack.Options(1), Pack.Asset, Pack.RFR, Method, 100, 200);

Pack.Asset.Vol = [15 30];
Pack.Asset.VolatilityModel = VolatilityModel.Uncertain;
[p_unc_neg, ~] = PriceOption(Pack.Options(1), Pack.Asset, Pack.RFR, Method, 100, 200);

%% Assertions
assert(abs(abs(p_min_pos)-abs(p_min_neg))<1e-5, 'Certain volatilitty must give same price for long and short positions');
assert(abs(abs(p_max_pos)-abs(p_max_neg))<1e-5, 'Certain volatilitty must give same price for long and short positions');
assert(abs(p_unc_pos)>abs(p_unc_neg), 'Uncertain volatilitty must give higher price for long position');
fprintf('All tests passed succesfully\n');

clear variables
clear imports