clear all
close all

Asset.Spot = 5;
Asset.VolatilityModel = VolatilityModel.Constant;
Asset.Vol = 20;

Option.Strike = 8;
Option.Term = 1;
Option.Type = OptionType.Call;
Option.Kind = OptionKind.Vanilla;
RFR = 5;


%for i = 1:20
%    i
%    v_exp(i) = PriceOption(Option, 'Explicit', i*10);
%    v_imp(i) = PriceOption(Option, 'Implicit', i*10);
%end

[v_x, surface_x] = PriceOption(Option, Asset, RFR, FDMScheme.Explicit, 30);
%[v1, surface1] = PriceOption(Option, 'Implicit', 150);

Pack.Asset.Spot = 5;
Pack.Asset.VolatilityModel = VolatilityModel.Constant;
Pack.Asset.Vol = 20;
Pack.RFR = 5;

Option1.Term = 1;
Option1.Kind = OptionKind.Vanilla;
Option1.Strike = 8;
Option1.Type = OptionType.Call;

Option2.Term = 0.5;
Option2.Kind = OptionKind.Digital;
Option2.Strike = 12;
Option2.Type = OptionType.Put;

Pack.Options(1) = Option1;
Pack.Options(2) = Option2;

N = 100;
[v2, surface2, K] = PriceOptionPack(Pack, FDMScheme.Explicit, N);
[v1, surface1] = PriceOptionPack(Pack, FDMScheme.Implicit, N, K);