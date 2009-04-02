function [ finalPrototypes  ] = KMeans( inputData, useFuzzy )
%KMEANS Summary of this function goes here
%   Detailed explanation goes here

    if(nargin < 2)
       useFuzzy = 0; 
    end

    points = inputData(1:2, :);
    prototypes = KM_SelectInitialPrototypes(inputData);
    
    if(useFuzzy == 0)
        prototypeUpdate = UpdatePrototypes(points, prototypes);
    else
        prototypeUpdate = FuzzyPrototypeUpdate(points, prototypes);
    end
	
    prototypeChange = sum(sum(abs(prototypes - prototypeUpdate)));
    
    iterationCount = 0;
    
    while (prototypeChange > 0)
        
        prototypes = prototypeUpdate;
        
        if(useFuzzy == 0)
            prototypeUpdate = UpdatePrototypes(points, prototypes);
        else
            prototypeUpdate = FuzzyPrototypeUpdate(points, prototypes);
        end
        
        prototypeChange = sum(sum(abs(prototypes - prototypeUpdate)));
        
        iterationCount = iterationCount + 1;
        
        if iterationCount > 100
            prototypeChange
            warning('Iteration limit exceeded');
            break;
        end
    end

    iterationCount
    
    finalPrototypes = prototypes;
end

function [newPrototypes] = UpdatePrototypes(points, currentPrototypes)

    newPrototypes = zeros(size(currentPrototypes));
    pointCount = zeros(1, size(currentPrototypes, 2));
    
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

function [newPrototypes, probabilities] = FuzzyPrototypeUpdate(points, currentPrototypes)

    b = 2;

    newPrototypes = zeros(size(currentPrototypes));
    probabilities = FuzzyPointProbabilities(points, currentPrototypes, b);

    for cluster=1:size(currentPrototypes,2)
        for point=1:size(points,2)        
            newPrototypes(:,cluster) = newPrototypes(:,cluster) + probabilities(cluster,point)^b*points(:, point);
        end
        
        newPrototypes(:,cluster) = newPrototypes(:,cluster)./sum(probabilities(cluster,:).^b);

    end

end

function probabilities = FuzzyPointProbabilities(points, prototypes, b)

    distances = GetDistances(points, prototypes);
    probabilities = zeros(size(distances));
    
    for currentPoint=1:size(points,2)
        if(min(min(distances(:, currentPoint))) == 0) 
            %prototype right on a point
            probabilities(:, currentPoint) = eq(distances(:, currentPoint), zeros(size(distances(:, currentPoint))));
        else
            probabilities(:, currentPoint) = distances(:, currentPoint).^(-1/(b-1));
            divisor = sum(probabilities(:, currentPoint));
            probabilities(:, currentPoint) = probabilities(:, currentPoint)./divisor;
        end
    end
end