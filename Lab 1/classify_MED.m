function class=classify_MED(x, z)   
    [r, c] = size(z);
    dist = zeros(c, 1);
    
    for i = 1:c
        dist(i,1)=(x-z(:,i))' * (x-z(:,i));
    end;
    
    [minDist, class] = min(dist);
end