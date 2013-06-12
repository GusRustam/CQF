function [ val, y1, col_sum1, simplex1 ] = TryExtrapolate( simplex, y, col_sum, hpi, factor, func )
%TRYEXTRAPOLATE Reflect simplex highest point symmetrically to plane
%created by other points and scales by given factor
    ndims = size(simplex, 1);
    
    new_point = ((1-factor)/ndims)*col_sum - simplex(:,hpi)*((1-factor)/ndims-factor);
    val = func(new_point);
    simplex1 = simplex;
    y1 = y;
    if val < y(hpi) 
        y1(hpi) = val;
        col_sum1 = col_sum + new_point - simplex1(:,hpi);
        simplex1(:,hpi) = new_point;
    else
        col_sum1 = col_sum;        
    end
end

