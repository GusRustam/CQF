function [ res ] = convert_to_forward( rates, terms )
    res = [rates(1) rates(2:end)+diff(rates)./diff(terms).*terms(2:end)];
end

