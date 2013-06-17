%% Setting up environment
clear variables
close all

import enums.*
import pricing.*
import optima.*

%% Initializing main option and package

% Main option
MainOption.Kind = OptionKind.Digital;
MainOption.Type = OptionType.Call;
MainOption.Strike = 20;
MainOption.Term = 1;
MainOption.Amount = 1;

% Asset and volatility model
Asset.Spot = 15;
Asset.Vol = [20 30];
Asset.VolatilityModel = VolatilityModel.Uncertain;

% Scheme and grid
Method = FDMScheme.Implicit;
Grid = [100 150];

% Packing
Pack.Asset = Asset;
Pack.Options(1) = MainOption;
Pack.RFR = 7; % todo uncertain rate?

%% Initializing optimizable options
Pack.Options(2).Kind = OptionKind.Vanilla;
Pack.Options(2).Type = OptionType.Call;
Pack.Options(2).Strike = 20;
Pack.Options(2).Term = 1;

Pack.Options(3).Kind = OptionKind.Vanilla;
Pack.Options(3).Type = OptionType.Call;
Pack.Options(3).Strike = 10;
Pack.Options(3).Term = 1;
% Pack.Options(3).Kind = OptionKind.Vanilla;
% Pack.Options(3).Type = OptionType.Put;
% Pack.Options(3).Strike = 20;
% Pack.Options(3).Term = 1;

% Pack.Options(4).Kind = OptionKind.Vanilla;
% Pack.Options(4).Type = OptionType.Call;
% Pack.Options(4).Strike = 10;
% Pack.Options(4).Term = 1;
% 
% Pack.Options(5).Kind = OptionKind.Vanilla;
% Pack.Options(5).Type = OptionType.Put;
% Pack.Options(5).Strike = 10;
% Pack.Options(5).Term = 1;

Vol = 25; % volatility for single options

func = @(amounts) PackPrice(Repackage(Pack, amounts), Method, Grid, Vol);

NumDims = 2;
Tolerance = 1e-2;

%% Calculate surface
if NumDims == 2
    amX = -1:0.1:1;
    amY = -1:0.1:1;
    srfc = zeros(length(amX), length(amY));
    minval = 1e10;
    for i = 1:length(amX)
        for j = 1:length(amY)
            srfc(i,j) =  func([amX(i) amY(j)]');
            if srfc(i,j) < minval
                minval = srfc(i,j);
                minX = amX(i);
                minY = amY(j);
            end
        end
    end
    mesh(srfc);figure(gcf);
    fprintf(['Minimum is located at (' num2str(minX) ', ' num2str(minY) ...
             '), value is ' num2str(minval) '\n']);
    pause
    close all
end

%% Calculate optimum
global trace;
trace = zeros(1, NumDims+1);
[val, point] = Optimize(func, zeros(1, NumDims), 1, Tolerance);
if NumDims == 2
    fprintf(['Minimum is located at (' num2str(point(1)) ', ' num2str(point(2)) ...
             '), value is ' num2str(val) '\n']);
end

%% Plot path
plot3(trace(:,1),trace(:,2),trace(:,3))
grid on
axis square

pause
close all