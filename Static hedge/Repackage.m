function [ Pack ] = Repackage( Pack, Amounts )
%REPACKAGE Changes number of options in package for all except for the
%first one
    global trace;
    
    trace = [trace; [Amounts' 0]];
    
    str = 'Repackage (';
    for i = 1:length(Amounts)
        str = [str num2str(Amounts(i)) ' '];
    end
    str = [str ')\n'];
    fprintf(str);
    if length(Amounts) ~= length(Pack.Options)-1
        throw(MException('Repackage:InvalidOperation', ...
                'Number of amounts must be one less then number of options'));
    end
    for i = 1:length(Amounts)
        Pack.Options(i+1).Amount = Amounts(i);
    end
end

