function class=classify_GED(x, z, sigma)
    [r, c] = size(z);
    dist = zeros(c, 1);
    
    for i = 1:c
        dist(i,1)=(x-z(:,i))' * inv(sigma(:,i*2-1:i*2)) * (x-z(:,i));
    end;
    
    [minDist, class] = min(dist);
end