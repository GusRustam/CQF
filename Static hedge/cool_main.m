Option.Type = 'Digital';
Option.Kind = 'Call';
Option.Strike = 10;

Asset.Spot = 5;
Asset.Volatility = 20;

Engine.Type = 'FDM';
Engine.Methond = 'Explicit';
Engine.Volatility = 'Constant';

RiskFreeRate = 7;

[simpleValue, valueSurface] = PriceOption(Option, Asset, RiskFreeRate, Engine);