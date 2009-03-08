function Deliverable1_SeqDisc( A, B)

    for i=1:3

        trainingDataRatio = 0.15;
        
        [trainA, otherA] = SeparateData(A, trainingDataRatio);
        [trainB, otherB] = SeparateData(B, trainingDataRatio);

        classifier = DiscriminateClassifier(...
            trainA,...
            trainB, i+1);

        PlotData(otherA, otherB, classifier);

    end
    
end

function PlotData(A, B, classifier)

    figure;
    hold on;
    
    plot(A(:, 1), A(:, 2), '.r', 'MarkerSize', 10);
    plot(B(:, 1), B(:, 2), '.g', 'MarkerSize', 10);
    
    start1 = 0; %min(min(A));
    end1 = 500; %max(max(A));
    
    start2 = 0;%min(min(B));
    end2 = 500;%max(max(B));
    
    contour(start1:end1, start2:end2, classifier.GenerateContourMatrix([start1 end1], [start2 end2]), 1, 'b-', 'LineWidth', 2);

end
