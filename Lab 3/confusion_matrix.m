function [confusion, error] = confusion_matrix(test, z, sigma)

    count = max(test(3, :));
    confusion = zeros(count,count);
    
    for i=1:size(test, 2)
        correct = test(3, i);
        classified = classify_ML_gaussian(test(1:2, i), z, sigma);
        confusion(correct, classified) = confusion(correct, classified) + 1;
    end
    
    error = zeros(count, 1);
    
    for i=1:count
        error(i) = confusion(i, i)/sum(confusion(i, :));
    end
    
end
