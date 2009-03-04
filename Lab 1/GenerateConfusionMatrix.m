function [confusionMatrix, probOfError] = GenerateConfusionMatrix( testData, arg1, arg2, fhandle)
%ERRORANALYSIS Summary of this function goes here
%   Detailed explanation goes here

    classCount = max(testData(3, :));
    confusionMatrix = zeros(classCount,classCount);

    for i=1:size(testData,2)
        correctClass = testData(3, i);
        classifiedAs = fhandle(testData(1:2, i), arg1, arg2);
        confusionMatrix(correctClass , classifiedAs) = confusionMatrix(correctClass, classifiedAs) + 1;
    end
    
    diagSum = sum(diag(confusionMatrix));
    totalSum = sum(sum(confusionMatrix));
    
    probOfError = (totalSum - diagSum)/totalSum;
end
