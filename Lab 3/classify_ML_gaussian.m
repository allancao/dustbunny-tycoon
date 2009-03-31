function class=classify_ML_gaussian(x, z, sigma)

    [r, c] = size(z);
    dist = zeros(c, 1);
    
    for i = 1:c
%         sigma(:, :, i)
%         det(sigma(:, :, i))
%         inv(sigma(:, :, i)) 
%         (x-z(:,i))
%         (x-z(:,i))' * inv(sigma(:, :, i)) * (x-z(:,i))
%         1 / (2*pi * sqrt(det(sigma(:, :, i))))
%         test=1 / (2*pi * sqrt(det(sigma(:, :, i))))*(x-z(:,i))' * inv(sigma(:, :, i)) * (x-z(:,i))
        
        dist(i) = 1 / (2*pi * sqrt(det(sigma(:, :, i)))) * ...
            exp(-0.5 * (x-z(:,i))' * inv(sigma(:, :, i)) * (x-z(:,i)));
        %dist(i);
    end
    
    [maxDist, class] = max(dist);