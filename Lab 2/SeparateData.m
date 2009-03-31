
function [prunedSource, prunedElements] = SeparateData(source, desiredRatio)

    if(desiredRatio >= 1)
        prunedSource = source;
        prunedElements = [];
        return;
    end

    mask = ge(desiredRatio*size(source,1), randperm(size(source,1)))';

    prunedSource = RemoveElements(source, mask);
    prunedElements = RemoveElements(source, ~mask);
    
    %TEST - ratio:
    %size(prunedSource, 1)/size(source, 1)
    
end