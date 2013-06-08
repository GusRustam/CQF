function [ res ] = convert_to_spot( rates, terms )
    res = [rates(1) (cumsum(rates(2:end).*diff(terms))+rates(1)*terms(1))./terms(2:end)];
end

