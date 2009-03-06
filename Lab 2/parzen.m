function parzen(data, dist, params, parzen_sigma, xmin, xmax)

    hold on
    x = xmin:.001:xmax;

    if(strcmp(dist, 'gaussian'))
        true_p_x = exp(-(x - params(1)).^2/(2 * params(2))^2)/(sqrt(2 * pi) * params(2));
    elseif(strcmp(dist, 'exp'))
        true_p_x = params * exp(-params * x) .* heaviside(x);
    end
    plot(x, true_p_x, 'r');

    est_p_x = zeros(length(parzen_sigma), length(x));
    window = zeros(length(data), length(x));
    colors = 'gbcmy';
    
    for i = 1:length(parzen_sigma)
        for j = 1:length(data)
            window(j, :) = exp(-(x - data(j)).^2/(2 * parzen_sigma(i))^2)/(sqrt(2 * pi) * parzen_sigma(i));
        end
        est_p_x(i, :) = sum(window)/length(data);
        plot(x, est_p_x(i, :), colors(i));
    end    

hold off