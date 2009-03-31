function Deliverable1_SeqDisc( A, B, trainingDataRatio)

    figure;
    hold on;

    plot(A(:, 1), A(:, 2), '.r', 'MarkerSize', 10);
    plot(B(:, 1), B(:, 2), '.b', 'MarkerSize', 10);

    return;
    
    if(nargin < 3)
        trainingDataRatio = 0.15;
    end

    for i=1:3
        
        [trainA, otherA] = SeparateData(A, trainingDataRatio);
        [trainB, otherB] = SeparateData(B, trainingDataRatio);

        classifier = DiscriminateClassifier(...
            trainA,...
            trainB);

        PlotData(classifier, trainingDataRatio);

        plot(trainA(:, 1), trainA(:, 2), '.r', 'MarkerSize', 10);
        plot(trainB(:, 1), trainB(:, 2), '.g', 'MarkerSize', 10);
        
        if (size(otherA, 1) ~= 0 && size(otherB, 1) ~= 0)
            plot(otherA(:, 1), otherA(:, 2), 'xr');
            plot(otherB(:, 1), otherB(:, 2), 'xg');
        end

    end
    
end

function PlotData(classifier, ratio)

    figure('Name', sprintf('Training Ratio: %g', ratio));
    hold on;

    start1 = 0; %min(min(A));
    end1 = 500; %max(max(A));
    
    start2 = 0;%min(min(B));
    end2 = 500;%max(max(B));
    
    contour(start1:end1, start2:end2, classifier.GenerateContourMatrix([start1 end1], [start2 end2]), 1, 'b-', 'LineWidth', 2);

end
