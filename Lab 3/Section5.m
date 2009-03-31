function Section5( data )
%SECTION5 Summary of this function goes here
%   Detailed explanation goes here

    PlotKMeans(data, KMeans(data), 'Regular k-means');
    PlotKMeans(data, KMeans(data, 1), 'Fuzzy k-means'); %Fuzzy
    
end

function PlotKMeans(data, prototypes, title)

    figure('Name', title);
    hold on;
    
    plot(data(1, :), data(2, :), '.g');
    plot(prototypes(1,:),prototypes(2,:), ...
        'xr', ...
        'MarkerSize',10);

end