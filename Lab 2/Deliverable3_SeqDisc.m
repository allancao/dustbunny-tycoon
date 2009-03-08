function Deliverable3_SeqDisc( A, B )

    trainingDataRatio = 0.15;
    
    avgErr = zeros(5,1);

    for J = 1:5
        
        p_err = zeros(1, 20);
        
        for test=1:20
            [trainA, testA] = SeparateData(A, trainingDataRatio);
            [trainB, testB] = SeparateData(B, trainingDataRatio);
            classifier = DiscriminateClassifier(trainA, trainB, J);
            
            wrong = sum(classifier.Classify(testA) - 1);
            wrong = wrong + sum(abs(classifier.Classify(testB) - 2));
            
            p_err(test) = wrong/(size(testA, 1) + size(testB, 1));
            
        end
        
        avgErr(J) = mean(p_err);
        
    end
    
    avgErr
    
    
    figure;
    hold on;
    plot(avgErr);

end

