function Section5_4( data )
%SECTION5_4 Summary of this function goes here
%   Detailed explanation goes here

    [confusion, error, mean, sigma] = MICD_classifier(data, data);
        
    PlotStuff(data, mean, 0, 'Regular');
    PlotStuff(data, mean, 1, 'Fuzzy');
end

function PlotStuff(data, micdPrototypes, fuzzyParameter, title)
    
    markers = 'x+ds';%v^<>*ph';
    colors = 'rbrb';
    
    figure('Name', title);
    hold on;
    
    plot(data(1, :), data(2, :), '.g');
    plot(micdPrototypes(1,:), micdPrototypes(2,:), 'ok', 'MarkerSize',3, 'LineWidth', 2.5 );
    
    for i=1:4
        kMeans = KMeans(data, fuzzyParameter);
        plot(kMeans(1,:),kMeans(2,:), strcat(markers(i) , colors(i)), 'MarkerSize',10);
    end

end