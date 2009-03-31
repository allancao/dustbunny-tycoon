function class = classify_MED(x, z) 
%x - each column is a point
%Format (rows)
%   1: x1 coord
%   2: x2 coord

%z - A matrix containing the class prototypes
%Format (rows)
%   1: x1 coord
%   2: x2 coord

    distances = GetDistances(x, z);
    
    %sort each column
    [sorted, indicies] = sort(distances, 1);
    
    class = indicies(1, :);

end