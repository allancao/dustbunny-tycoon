
function prototypes = KM_SelectInitialPrototypes(points)
%prototypes: 2x10 matrix, each column is a prototype 

    indicies = randperm(size(points, 2));
    prototypes = zeros(2, 10);
    indicies(1:10)
    
    for i=1:10
        prototypes(:, i) = points(1:2, indicies(i));
    end

end