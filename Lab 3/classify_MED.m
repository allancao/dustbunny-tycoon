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
    class = ClassifyByDistance(distances);
    
end

function distances = GetDistances(points, prototypes)
%distances: Each column corresponds to a point
% Elements are the distances to the other prototypes (10)

    distFeature1 = zeros(size(prototypes, 2), size(points, 2));
    distFeature2 = zeros(size(prototypes, 2), size(points, 2));
    
    %iterate rows to determine the distance to each prototype for a given feature 
    for i = 1:size(prototypes, 2)
        distFeature1(i, :) = points(1, :) - ones(1, size(points, 2))*prototypes(1, i);
    end
    for i = 1:size(prototypes, 2)
        distFeature2(i, :) = points(2, :) - ones(1, size(points, 2))*prototypes(2, i);
    end
    
    %find the distance in each feature direction 
    distances = (distFeature1.^2 + distFeature2.^2).^(1/2);
    
end

function classification = ClassifyByDistance(distances)
%classification: row vector, each element is the index of
    
    %sort each column
    [sorted, indicies] = sort(distances, 1);
    
    classification = indicies(1, :);

end

