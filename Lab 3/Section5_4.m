function Section5_4( data )
%SECTION5_4 Summary of this function goes here
%   Detailed explanation goes here

    [confusion, error, mean, sigma] = MICD_classifier(data, data)
    kMeans = KMeans(data);
    %kMeansFuzz = KMeans(data, 1);
    
    figure;
    hold on;
    
    plot(data(1, :), data(2, :), '.g');
    plot(mean(1,:),mean(2,:), 'ok', 'MarkerSize',10);
    plot(kMeans(1,:),kMeans(2,:), 'xr', 'MarkerSize',10);
    %plot(kMeansFuzz(1,:),kMeansFuzz(2,:), 'xb', 'MarkerSize',10);
    
end
