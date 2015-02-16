function hsvStdImage = getBackgroundStd( nBackgrounds, nRows, nCols, hsvMeanImg )

    % Split HSV mean image into its 3 channels
    hMeanImg = hsvMeanImg(:,:,1);
    sMeanImg = hsvMeanImg(:,:,2);
    vMeanImg = hsvMeanImg(:,:,3);
    
    % Set squared difference placeholders
    squaredDiffH = double(zeros(nRows, nCols, 1));
    squaredDiffS = squaredDiffH;
    squaredDiffV = squaredDiffH;
    
    % Loop through each pixel finding the squared difference from the mean
    for h = 1 : nBackgrounds
        imgTmp = rgb2hsv(imread(['emptybelt', num2str(h), '.jpg']));
        channelH = imgTmp(:,:,1);
        channelS = imgTmp(:,:,2);
        channelV = imgTmp(:,:,3);
        for i = 1 : nRows
            for j = 1 : nCols
                currentDifH = channelH(i, j) - hMeanImg(i, j);
                currentSqDifH = (currentDifH)^2;
                squaredDiffH(i, j) = squaredDiffH(i, j) + (currentSqDifH);
                currentDifS = channelS(i, j) - sMeanImg(i, j);
                currentSqDifS = (currentDifS)^2;
                squaredDiffS(i, j) = squaredDiffS(i, j) + (currentSqDifS);
                currentDifV = channelV(i, j) - vMeanImg(i, j);
                currentSqDifV = (currentDifV)^2;
                squaredDiffV(i, j) = squaredDiffV(i, j) + (currentSqDifV);
            end
        end
    end
    
    % Variance found by averaging the squared difference
    varianceH = squaredDiffH / nBackgrounds;
    varianceS = squaredDiffS / nBackgrounds;
    varianceV = squaredDiffV / nBackgrounds; 
    
    % Standard deviation found by square rooting the variance
    hStdImg = sqrt(varianceH);
    sStdImg = sqrt(varianceS);
    vStdImg = sqrt(varianceV);
    
    % Concatenate channel std images to get HSV std image
    hsvStdImage = cat(3, hStdImg, sStdImg, vStdImg);
    
end