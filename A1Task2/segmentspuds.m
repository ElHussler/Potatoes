function outIm = segmentspuds( inputImage )
    
    rgbPotatoesIn = imread(inputImage);
    hsvPotatoesIn = rgb2hsv(rgbPotatoesIn);
    [nRows, nCols] = size(rgbPotatoesIn(:,:,1));
    
    % Get number of empty belt images in current folder
    backgrounds = dir('empty*.jpg');
    nBackgrounds = length(backgrounds(not([backgrounds.isdir])));

    % Generate HSV mean & standard deviation background models
    hsvMeanImg = getBackgroundMean(nBackgrounds, nRows, nCols);
    hsvStdImg = getBackgroundStd(nBackgrounds, nRows, nCols, hsvMeanImg);
    
    % Filter background models to reduce prominence of dark roller boundaries
    blurFilter = fspecial('motion', 22);
    blurredHsvMean = imfilter(hsvMeanImg, blurFilter, 'circular');
    blurredHsvStd = imfilter(hsvStdImg, blurFilter, 'circular');
    
    % K-Means clustering (region-based approach to segmentation)
    % Clusters mean and std image pixels into 5 colours to normalise the background models' pixel values
    [backgroundM, backgroundS] = kMeansCluster(blurredHsvMean, blurredHsvStd);

    % Contrast stretch input HSV potato image to increase contrast between potatoes and rollers
    potatoIn = imadjust(hsvPotatoesIn, stretchlim(hsvPotatoesIn));
    
    % Create binary image using background model (mean & std)
    binaryMask = im2bw(zeros(nRows, nCols, 1));
    intensityThresh = 0.22;
    % COLOUR SLICING; Mask indicates a potato if...
    % The pixel intensity is greater than a threshold (found via roipoly and imhist), and the pixel saturation 
    % is greater than the background mean saturation plus the background standard deviation intensity
    for i = 1 : nRows
        for j = 1 : nCols
            if (potatoIn(i,j,3) > intensityThresh)
                if (potatoIn(i,j,2) > (backgroundM(i,j,2) + backgroundS(i,j,3)))
                    binaryMask(i,j) = 1;
                end
            end
        end
    end
    
    % Dilate, fill holes, remove small components, erode, filter, and
    % remove any remaining smaller components to produce final mask
    se = strel('disk', 4);
    binaryMask = imdilate(binaryMask, se);
    binaryMask = imfill(binaryMask,'holes');
    binaryMask = removeComponents(binaryMask, 500);
    binaryMask = imerode(binaryMask, se);
    binaryMask = medfilt2(binaryMask, [5 5]);
    binaryMask = removeComponents(binaryMask, 300);
    
    % Apply mask to input image
    outIm = imread(inputImage);    
    for i = 1 : nRows
        for j = 1 : nCols
            if binaryMask(i, j) == 0
                outIm(i,j,:) = [0 0 0];
            else
                outIm(i,j,1) = outIm(i,j,1);
                outIm(i,j,2) = outIm(i,j,2);
                outIm(i,j,3) = outIm(i,j,3);
            end
        end
    end
    
    %%% TASK 1 FUNCTION APPLIED TO DISPLAY BOUNDING RECTANGLES AND SUMMARY STATISTICS FOR POTATOES %%%    
    % REGIONPROPS COMPILES SPECIFIC PROPERTIES OF ALL COMPONENTS (FOR PERFORMANCE)
    components = bwconncomp(binaryMask);
    objProperties = regionprops(components, 'centroid', 'majoraxis', 'minoraxis', 'boundingbox', 'image');
    centroids = cat(1, objProperties.Centroid);
    majorAxisLengths = cat(1, objProperties.MajorAxisLength);
    minorAxisLengths = cat(1, objProperties.MinorAxisLength);
    
    % OUTPUT FINAL IMAGE ON WHICH TO OVERLAY BOUNDING RECTANGLES
    figure('name', 'Final image'), imshow(outIm), title('Final image with Bounding Box');
    
    imageInName = strsplit(inputImage,'.');
    imageInNum = imageInName(1);
    
    % DISPLAY SUMMARY STATISTICS FOR CURRENT IMAGE
    disp(' --------------------------------------------------- SUMMARY STATISTICS -------------------------------------------------- ');
    disp(['| Potato Image: ', imageInNum{1}, sprintf('\t\t\t'), 'Potatoes Detected: ', num2str(components.NumObjects), sprintf('\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t'), '  |']);
    disp(' ------------------------------------------------------------------------------------------------------------------------- ');
    disp('| Potato # | Centroid (x,y) | Eccentricity  |   Mean (R, G, B)      | Standard Deviation (R, G, B) | Smoothness | Entropy |');
    
    hold on
    
    for i = 1: length(objProperties)
        
        % COMPUTE COMPONENT'S FOCI DISTANCE FOR ECCENTRICITY CALCULATION
        ellipseFociDistance = 2 * (sqrt((majorAxisLengths(i,1)/2)^2 - (minorAxisLengths(i,1)/2)^2));
        
        % BOUNDING BOX CO-ORDINATES 'CUT' OUT POTATO FOR STATISTIC CALCULATIONS
        % CUSTOM FUNCTION RETURNS VECTOR CONTAINING MEANS, STDS, SMOOTHNESS, AND ENTROPY
        componentMask = objProperties(i).Image;
        x = round(objProperties(i).BoundingBox(1));
        y = round(objProperties(i).BoundingBox(2));
        w = (objProperties(i).BoundingBox(3));
        h = (objProperties(i).BoundingBox(4));        
        resultStats = getTextureDescriptors(rgbPotatoesIn, componentMask, x, y, w, h);
        
        % FORMAT STATISTICS FOR DISPLAY
        potatoNum = num2str(i);
        centroidX = num2str(round(centroids(i,1)));
        centroidY = num2str(round(centroids(i,2)));
        ecc = num2str(ellipseFociDistance/majorAxisLengths(i,1));
        meanR = num2str(round(resultStats(1)));
        meanG = num2str(round(resultStats(2)));
        meanB = num2str(round(resultStats(3)));
        stdR = num2str(round(resultStats(4)));
        stdG = num2str(round(resultStats(5)));
        stdB = num2str(round(resultStats(6)));
        smoothn = num2str(resultStats(7));
        entro = num2str(resultStats(8));
        
        tab = sprintf('\t');
        
        % DISPLAY SUMMARY STATISTICS FOR CURRENT POTATO
        disp(' ------------------------------------------------------------------------------------------------------------------------- ');
        disp(['|    ', potatoNum, tab, '   |   (' centroidX, ', ' , centroidY, ')' tab,...
              '|   ', ecc, tab, tab, '|   (', meanR, ',', tab, meanG, ',   ', meanB, ')' tab, '|', tab, tab,...
              ' (', stdR, ', ', stdG, ', ', stdB, ')', tab, tab, '   |  ', smoothn, tab, '| ', entro, '  |']);
        
        % OVERLAYS BOUNDING BOX ON FIGURE, UNCOMMENT BELOW TO PLOT CENTROID
        % plot(centroids(:,1), centroids(:,2), 'ro');
        rectangle('Position', objProperties(i).BoundingBox,'edgecolor','g');
    end
    
    hold off
    
    disp(' ------------------------------------------------------------------------------------------------------------------------- ');
    
end

% REF: average background, smooth/blur image, bg subtraction
%      http://studentdavestutorials.weebly.com/basic-image-processing-with-matlab.html
% REF: HSV good, segmentation by clustering, determines threshold (imhist) for segmenting foreground pixels, 
%      http://www.computer-vision.org/4security/pdf/4-ali.pdf
%      HSV good: http://iris.usc.edu/Outlines/papers/1999/francois-cisst99.pdf
%      BG sub in HSV: http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.81.3145
% REF: DIR http://uk.mathworks.com/help/matlab/ref/dir.html?nocookie=true