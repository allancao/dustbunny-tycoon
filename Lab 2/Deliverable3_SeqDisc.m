function [avgErr, stdErr, maxErr, minErr] = Deliverable3_SeqDisc( A, B, trainingDataRatio )

    if(nargin < 3)
        trainingDataRatio = 0.1;
    end
    
    avgErr = zeros(5,1);
    minErr = zeros(5,1);
    maxErr = zeros(5,1);
    stdErr = zeros(5,1);

    j_max = 5;
    
    for J = 1:j_max
        
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
        minErr(J) = min(p_err);
        maxErr(J) = max(p_err);
        stdErr(J) = std(p_err);
        
    end
    
    figure('Name', sprintf('Training data ratio: %g', trainingDataRatio));
    %hold on;
    %'LineWidth', 2.5, 
    plot( ...
        1:j_max, avgErr, 'r', ...
        1:j_max, stdErr, '--r', ...    
        1:j_max, minErr, 'g', ...
        1:j_max, maxErr, 'b');
    
    h = legend('Avg','Std','Min','Max',1);
    set(h,'Interpreter','none')
    
    %plot(stdErr, 'r', 'LineStyle', '--');
    
    %plot(minErr, 'g');
    %plot(maxErr, 'b');

end

