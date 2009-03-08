function cleared = RemoveElements(toRemove, mask)
    
    cleared = toRemove;

    if(size(mask, 2) > 1)
        error('Mask size error')
    end

    for i = 0:(size(toRemove, 1) - 1)
        i = size(toRemove, 1) - i;
        if(mask(i, 1) == 0)
            cleared(i, :) = [];
        end
    end
end
