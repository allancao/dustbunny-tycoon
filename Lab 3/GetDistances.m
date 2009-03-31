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