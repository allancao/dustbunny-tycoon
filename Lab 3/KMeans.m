function [ finalPrototypes  ] = KMeans( inputData )
%KMEANS Summary of this function goes here
%   Detailed explanation goes here

    points = inputData(1:2, :);
    prototypes = SelectInitialPrototypes(inputData);
    
    prototypeUpdate = UpdatePrototypes(points, prototypes);
	prototypeChange = sum(sum(abs(prototypes - prototypeUpdate)));
    
    iterationCount = 0;
    
    while (prototypeChange > 0)
        
        prototypes = prototypeUpdate;
        
        prototypeUpdate = UpdatePrototypes(points, prototypes);
        prototypeChange = sum(sum(abs(prototypes - prototypeUpdate)));
        
        iterationCount = iterationCount + 1;
        
        if iterationCount > 100
            error('Iteration limit exceeded');
        end
    end

    iterationCount
    
    finalPrototypes = prototypes;
end

function prototypes = SelectInitialPrototypes(points)
%prototypes: 2x10 matrix, each column is a prototype 

    indicies = randperm(size(points, 2));
    prototypes = zeros(2, 10);
    
    for i=1:10
        prototypes(:, i) = points(1:2, indicies(i));
    end

end

function [newPrototypes] = UpdatePrototypes(points, currentPrototypes)

    newPrototypes = zeros(size(currentPrototypes));
    pointCount = zeros(1, size(currentPrototypes, 2));
    
    %distances = GetDistances(points, currentPrototypes);
    %classified = ClassifyByDistance(distances);
    
    classified = classify_MED(points, currentPrototypes);
    
    for currentPoint = 1:size(points, 2)
        
        cluster = classified(currentPoint);
        
        %Update the new prototype with the point
        newPrototypes(:, cluster) = newPrototypes(:, cluster) + points(:, currentPoint);
        
        pointCount(cluster) = pointCount(cluster) + 1;
    end
    
    if(min(min(pointCount)) == 0)
        pointCount
        Error('No points in a cluster'); 
    end
    
    %Average it out - I think there should be some way to do this in one step 
    newPrototypes(1,:) = newPrototypes(1,:)./pointCount;
    newPrototypes(2,:) = newPrototypes(2,:)./pointCount;
    
    
end

