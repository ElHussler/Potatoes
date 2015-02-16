function results = getTextureDescriptors( input, componentMask, x, y, w, h )
    
    % MANUALLY CALCULATE THE MEAN, STD, SMOOTHNESS AND ENTROPY OF THE INPUT OBJECT
    count = 0;
    pixelsR = double(0);
    pixelsG = double(0);
    pixelsB = double(0); 
    pixelsGray = double(0);   
    squaredDiffR = int32(0);
    squaredDiffG = int32(0);
    squaredDiffB = int32(0);
    squaredDiffGray = int32(0);
    channelR = input(y:((y+h) - 1), x:((x+w) - 1), 1);
    channelG = input(y:((y+h) - 1), x:((x+w) - 1), 2);
    channelB = input(y:((y+h) - 1), x:((x+w) - 1), 3);
    imageGray = input(y:((y+h) - 1), x:((x+w) - 1));

    % ACCUMLUATE NON-ZERO PIXELS' VALUES AND TOTAL PIXEL COUNT
    for i = 1 : h
        for j = 1 : w
            % COMPONENTMASK ENSURES NO POTATO DATA FROM OVERLAPPING BOUNDING BOXES IS USED
            if componentMask(i, j) ~= 0 
                pixelsR = pixelsR + double(channelR(i, j));
                pixelsG = pixelsG + double(channelG(i, j));
                pixelsB = pixelsB + double(channelB(i, j));
                pixelsGray = pixelsGray + double(imageGray(i, j));
                count = count + 1;
            end
        end
    end
    
    % MEAN DIVIDES TOTAL PIXEL VALUE BY TOTAL PIXEL COUNT
    meanR = pixelsR / count;
    meanG = pixelsG / count;
    meanB = pixelsB / count;
    meanGray = pixelsGray / count;
    
    % ACCUMULATE SQUARED DIFFERENCE VALUES
    for i = 1 : h
        for j = 1 : w
            if componentMask(i, j) ~= 0
                squaredDiffR = squaredDiffR + ((int32(channelR(i, j)) - int32(meanR))^2);
                squaredDiffG = squaredDiffG + ((int32(channelG(i, j)) - int32(meanG))^2);
                squaredDiffB = squaredDiffB + ((int32(channelB(i, j)) - int32(meanB))^2);
                squaredDiffGray = squaredDiffGray + ((int32(imageGray(i, j)) - int32(meanGray))^2);
            end
        end
    end
    
    % VARIANCE DIVIDES TOTAL SQUARED DIFFERENCE VALUE BY TOTAL PIXEL COUNT
    varianceR = squaredDiffR / count;
    varianceG = squaredDiffG / count;
    varianceB = squaredDiffB / count;
    varianceGray = squaredDiffGray / count;
    
    % STANDARD DEVIATION SQUARE ROOTS THE VARIANCE
    stdR = sqrt(double(varianceR));
    stdG = sqrt(double(varianceG));
    stdB = sqrt(double(varianceB));
    
    % SMOOTHNESS OF GRAYSCALE INPUT GIVES VALUE IN [0, 1]
    smoothness = (1 - 1 / (1 + double(varianceGray)));
    
    % ENTROPY REMOVES 'ZERO' HISTOGRAM COUNTS, NORMALISES, SUMS COUNTS
    binCounts = imhist(imageGray);
    binCounts(binCounts == 0) = [];
    grayElements = numel(imageGray);
    normalisedCounts = (binCounts ./ grayElements);
    entro = -(sum(normalisedCounts .* log2(normalisedCounts)));

    results = [meanR, meanG, meanB, stdR, stdG, stdB, smoothness, entro];    
end