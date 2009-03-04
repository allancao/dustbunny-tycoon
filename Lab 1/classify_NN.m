function class = classify_NN(point, data)

    [m, n] = size(data);
    
    if (m ~= 3)
        class = -2;
        return;
    end

    lastDistance = 1000;
    class = -1;

    for i=1:n
        dist = ((point(1,1) - data(1, i))^2 + (point(2,1) - data(2, i))^2)^(1/2);
        if  dist < lastDistance
            %[data(1, i), data(2, i), data(3, i), dist]
            lastDistance = dist;
            class = data(3, i);
        end
    end
end

