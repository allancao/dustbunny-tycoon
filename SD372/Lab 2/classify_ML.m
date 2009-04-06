function class=classify_ML(x, z, sigma, n)

    [r, c] = size(z);
    dist = zeros(c, 1);
    
    for i = 1:c
        dist(i,1) = 1 / (2*pi * sqrt(det(sigma(:, :, i)))) * ...
            exp(-0.5 * (x-z(:,i))' * inv(sigma(:, :, i)) * (x-z(:,i)));
    end;
    
    [maxDist, class] = max(dist);
    