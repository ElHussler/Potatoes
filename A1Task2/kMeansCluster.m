function [clusteredMean, clusteredStd] = kMeansCluster( blurredHsvMean, blurredHsvStd )

    % Trial & error found 5 colours gave the best representation of the background
    nColors = 5;
    [nRows, nCols, nChannels] = size(blurredHsvMean);
    reshapedMean = reshape(blurredHsvMean, nRows * nCols, nChannels);
    reshapedStd = reshape(blurredHsvStd, nRows * nCols, nChannels);
    [clustersM, centroidsM] = kmeans(reshapedMean, nColors, 'maxiter', 300);
    [clustersS, centroidsS] = kmeans(reshapedStd, nColors, 'maxiter', 300);
    
    % Placeholder images for k-means clustered outputs
    clusteredMean = zeros(size(blurredHsvMean));
    clusteredStd = zeros(size(blurredHsvStd));
    
    for i = 1 : nRows
        for j = 1 : nCols
            for k = 1 : nChannels
                clusteredMean(i, j, k) = centroidsM(clustersM(((j - 1) * nRows) + i), k);
                clusteredStd(i, j, k) = centroidsS(clustersS(((j - 1) * nRows) + i), k);
            end
        end
    end

end