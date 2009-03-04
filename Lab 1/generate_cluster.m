function dist=generate_cluster(n, mean, sigma, color, plotDistribution)
    dist = randn(2,n);
    [V, D] = eig(sigma);
    sqrtD = sqrt(D);
    dist = V * sqrtD * dist + [ones(1,n).* mean(1) ; ones(1,n).* mean(2)];
    
    if plotDistribution ~= true
       return; 
    end
    
    plot(dist(1,:), dist(2,:), strcat('.', color));
    plot_ellipse(mean(1), mean(2), atan(V(1, 2)/V(1, 1)), sqrtD(1,1)*2, sqrtD(2,2)*2, color);