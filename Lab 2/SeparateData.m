
function [prunedSource, prunedElements] = SeparateData(source, desiredRatio)

    mask = ge(desiredRatio, rand(size(source,1), 1));

    prunedSource = RemoveElements(source, mask);
    prunedElements = RemoveElements(source, ~mask);
    
end