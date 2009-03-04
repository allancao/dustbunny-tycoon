function class = classify_5NN( point, data)
%CLASSIFY_5NN Summary of this function goes here
%   Detailed explanation goes here

    n = 5;

    nearest = 1000*ones(n, 1);
    currentClass = data(3,1);
    
    for i = 1:size(data,2)
        
        %Determine what class we are checking distances for
        assert(data(3, i) >= currentClass);
        if data(3, i) > currentClass
            assert(data(3, i) == currentClass +1);
            nearest = [nearest 1000*ones(n, 1)];
            currentClass = data(3, i);
        end
        
        
        dist = ((point(1,1) - data(1, i))^2 + (point(2,1) - data(2, i))^2)^(1/2);
        
        if dist < nearest(n, currentClass)
            nearest(n, currentClass) = dist;
            nearest = sort(nearest, 1);
        end
        
    end

    nearest_2 = max(max(nearest));
    for i=1:size(nearest,2)
       if nearest(n,i) < nearest_2
           nearest_2 = nearest(n,i);
           class = i;
       end
    end
    
end
