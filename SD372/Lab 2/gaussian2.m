function [mean, sigma] = gaussian2(data, xmin, xmax, ymin, ymax, step)
    
    x = [xmin:step:xmax];
    y = [ymin:step:ymax];
    
    [n m c] = size(data);
    
    mean = zeros(c, m);
    sigma = zeros(m, m, c);
    sigma_j = zeros(m, m, n);

    for i = 1:c
        mean(i, :) = sum(data(:, :, i))/n;
        for j = 1:n
            sigma_j(:, :, j) = (data(j, :, i) - mean (i, :))' * (data(j, :, i) - mean (i, :));
        end
        sigma(:, :, i) = sum(sigma_j, 3)/n;
    end
    
    classifier = zeros(length(y),length(x));
    
    for i=1:length(y)
        for j=1:length(x)
            classifier(i, j)=classify_ML([x(j);y(i)], mean', sigma, n);
        end
    end
    
    hold on
    
    colors = 'rgb';    
    for i = 1:c      
        plot(data(:, 1, i), data(:, 2, i), strcat('.', colors(i)));
    end;
    
    contour(x, y, classifier, c-1, 'b-', 'LineWidth', 2);
    
    hold off
    