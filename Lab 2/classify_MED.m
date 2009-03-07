function class = classify_MED(x, z) 
%x - each row is a point
%Format (columns)
%   1: x1 coord
%   2: x2 coord

%z - a 2x2 matrix, each row is the prototype of a class
%Format (columns)
%   1: x1 coord
%   2: x2 coord

    if(size(z, 1) ~= 2 || size(z, 2) ~= 2 )
        error('z is the wrong size')
    end

    zExpander = ones(size(x,1),1);
    distToCls = [x - zExpander*z(1,:), x - zExpander*z(2,:)].^2;
    
    %TEST:
    %class = distToCls; return;
    
    %The ith row contains data for the ith poin in the x vector.
    %Format (colums)
    %   1: dist to class 1
    %   2: dist to class 2
    distToCls = [sum(distToCls(:,1:2), 2), sum(distToCls(:,3:4), 2)];
    
    %TEST:
    %distToCls = sqrt(distToCls); class = distToCls; return;
    
    class = sign(distToCls(:,2) - distToCls(:,1));%, 0);
    
    %Output format (columns)
    %   1: 1 if the point belongs to class 1
    %   2: 1 if the point belongs to class 2
    %row will be zero if tied
    class = [gt(class, 0), lt(class, 0)];
    
    return;
    
end

