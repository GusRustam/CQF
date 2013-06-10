clear all
close all

import pack.*
import pack.options.*
import pack.volatility.*

opt1 = VanillaOption(1, OptionType.Call, 20);
opt1.Value(10, SimpleVol(0.10), 0.05, FDM.Explicit, [30 30]);