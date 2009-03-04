function output = ConcatenateClasses( c1, c2, c3)
%CONCATENATECLASSES Summary of this function goes here
%   Detailed explanation goes here

    output = [c1 ; 1*ones(1, 1*size(c1, 2))];
    output = [output [c2 ; 2*ones(1, size(c2, 2))]];
    
    if c3 ~= 0
        output = [output [c3 ; 3*ones(1, size(c3, 2))]];
    end

end
