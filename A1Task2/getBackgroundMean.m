function hsvMeanImage = getBackgroundMean( nBackgrounds, nRows, nCols )

    % Set hsv channel placeholder images
    hImg = zeros(nRows, nCols, 1);
    sImg = hImg;
    vImg = hImg;
    
    % Loop through provided number of backgrounds adding pixel values
    for i = 1 : nBackgrounds
        imgTmp = rgb2hsv(imread(['emptybelt', num2str(i), '.jpg']));
        hImg = hImg + imgTmp(:,:,1);
        sImg = sImg + imgTmp(:,:,2);
        vImg = vImg + imgTmp(:,:,3);
    end
    
    % Mean for each channel found by dividing by number of backgrounds
    hMeanImg = hImg / nBackgrounds;
    sMeanImg = sImg / nBackgrounds;
    vMeanImg = vImg / nBackgrounds;
    
    % Concatenate channel mean images to get HSV mean image
    hsvMeanImage = cat(3, hMeanImg, sMeanImg, vMeanImg);
    
end