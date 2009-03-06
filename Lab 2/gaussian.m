function [mean, sigma] = gaussian(data, dist, params, xmin, xmax)

    mean = sum(data)/length(data);
    sigma = sum((data - mean).^2)/length(data);

    hold on
    x = xmin:.001:xmax;

    if(strcmp(dist, 'gaussian'))
        true_p_x = exp(-(x - params(1)).^2/(2 * params(2))^2)/(sqrt(2 * pi) * params(2));
    elseif(strcmp(dist, 'exp'))
        true_p_x = params * exp(-params * x) .* heaviside(x);
    end
    plot(x, true_p_x, 'r');

    est_p_x = exp(-(x - mean).^2/(2 * sigma)^2)/(sqrt(2 * pi) * sigma);
    plot(x, est_p_x, 'g');

hold off