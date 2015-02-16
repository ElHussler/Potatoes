function bwOutput = removeComponents(BW, pixelThresh)

    % FIND PIXEL COUNT OF EACH COMPONENT, SET ALL PIXELS TO ZERO IN ANY
    % COMPONENT BELOW THE THRESHOLD
    components = bwconncomp(BW);
    pixelCount = cellfun(@numel,components.PixelIdxList);
    [rows, cols] = size(pixelCount);
    
    for i = 1 : cols
        if (pixelCount(i) < pixelThresh)
            BW(components.PixelIdxList{i}) = 0;
        end
    end
    
    bwOutput = BW;
    
end

