clear all;
close all;

Option.Spot = 5;
Option.Strike = 8;
Option.RFR = 5;
Option.Vol = 20;
Option.Term = 1;
Option.Type = 'Call';
Option.Kind = 'Vanilla';
Option.VolatilityModel = 'Const';

%for i = 1:20
%    i
%    v_exp(i) = PriceOption(Option, 'Explicit', i*10);
%    v_imp(i) = PriceOption(Option, 'Implicit', i*10);
%end

[v_x, surface_x] = PriceOption(Option, 'Explicit', 30);
%[v1, surface1] = PriceOption(Option, 'Implicit', 150);

Pack.Asset.Spot = 5;
Pack.Asset.VolatilityModel = 'Const';
Pack.Asset.Vol = 20;
Pack.RFR = 5;

Option1.Term = 1;
Option1.Kind = 'Vanilla';
Option1.Strike = 8;
Option1.Type = 'Call';

Option2.Term = 0.5;
Option2.Kind = 'Digital';
Option2.Strike = 12;
Option2.Type = 'Put';

Pack.Options(1) = Option1;
Pack.Options(2) = Option2;

N = 100;
[v2, surface2, K] = PriceOptionPack(Pack, 'Explicit', N);
[v1, surface1] = PriceOptionPack(Pack, 'Implicit', N, K);