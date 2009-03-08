function GenerateDiscrimFigure( A, B)

    newplot;
    hold on;
    
    plot(A(:, 1), A(:, 2), '.r', 'MarkerSize', 10);
    plot(B(:, 1), B(:, 2), '.g', 'MarkerSize', 10);
    
    classifier = DiscriminateClassifier(A, B);
    
    %for j=1:size(classifier.G, 1)
    %   plot([classifier.G(j,1), classifier.G(j,3)], [classifier.G(j,2), classifier.G(j,4)], 'r', 'LineWidth', j);
    %end
    
    start1 = 0; %min(min(A));
    end1 = 500; %max(max(A));
    
    start2 = 0;%min(min(B));
    end2 = 500;%max(max(B));
    
    %size(start1:end1)
    %size(start2:end2)
    %size(classifier.GenerateContourMatrix([start1 end1], [start2 end2]))
    
    contour(start1:end1, start2:end2, classifier.GenerateContourMatrix([start1 end1], [start2 end2]), 1, 'b-', 'LineWidth', 2);
    
    hold off;

end

