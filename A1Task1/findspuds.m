function findspuds(imageName)
    %findspuds - detect and calculate potato statistics
    %   Written in 'MATLAB R2014b', in the event of compatibility issues with
    %   previous versions of MATLAB please use with specified version. Use RGB
    %   file name as input argument to locate potatoes and elicit statistical
    %   information for each.

    input = imread(imageName);
    imageInName = strsplit(imageName,'.');
    imageInNum = imageInName(1);
    imageOutName = strcat('.\output\', imageInNum, 'out', '.png');
    
    % MANUALLY CONVERT TO GRAYSCALE USING STANDARD NTSC CONVERSION FORMULA
    % MANUALLY CONVERT TO BINARY USING THRESHOLD OBTAINED THROUGH TESTING
    graySpuds = (0.2989 * input(:,:,1) + (0.5870 * input(:,:,2)) + (0.1140 * input(:,:,3)));
    bwSpuds = (graySpuds > (0.115*255));
    
    % CLOSE THIN GAPS TO ENCLOSE HOLES THAT ARE THEN FILLED MANUALLY
    bwSpuds = imclose(bwSpuds, strel('diamond', 1));
    bwSpuds = fillHoles(bwSpuds);
    
    % OPEN OPERATION PREVENTS JOINED OBJECTS
    bwSpuds = imopen(bwSpuds, strel('disk', 18));
    
    % REGIONPROPS COMPILES SPECIFIC PROPERTIES OF ALL COMPONENTS (FOR PERFORMANCE)
    components = bwconncomp(bwSpuds);
    objProperties = regionprops(components, 'centroid', 'majoraxis', 'minoraxis', 'boundingbox', 'image');
    centroids = cat(1, objProperties.Centroid);
    majorAxisLengths = cat(1, objProperties.MajorAxisLength);
    minorAxisLengths = cat(1, objProperties.MinorAxisLength);
    
    % OUTPUT FINAL IMAGE ON WHICH TO OVERLAY BOUNDING RECTANGLES
    figure('name', 'Final image'), imshow(input), title('Final image with Bounding Boxes');
    
    % DISPLAY SUMMARY STATISTICS FOR CURRENT IMAGE
    disp(' --------------------------------------------------- SUMMARY STATISTICS -------------------------------------------------- ');
    disp(['| Potato Image: ', imageInNum{1}, sprintf('\t\t\t'), 'Potatoes Detected: ', num2str(components.NumObjects), sprintf('\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t'), '  |']);
    disp(' ------------------------------------------------------------------------------------------------------------------------- ');
    disp('| Potato # | Centroid (x,y) | Eccentricity  |   Mean (R, G, B)      | Standard Deviation (R, G, B) | Smoothness | Entropy |');
    
    hold on
    
%     phi = linspace(0,2*pi,50);
%     cosphi = cos(phi);
%     sinphi = sin(phi);
    
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
        resultStats = getTextureDescriptors(input, componentMask, x, y, w, h);        
        
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
        disp(['|    ', potatoNum, tab, '   |   (' centroidX, ', ' , centroidY, ')' tab, '|   ', ecc, tab, tab,...
              '|   (', meanR, ',', tab, meanG, ',   ', meanB, ')' tab, '|', tab, tab, ' (', stdR, ', ', stdG,...
              ', ', stdB, ')', tab, tab, '   |  ', smoothn, tab, '| ', entro, '  |']);
        
        % OVERLAYS MINIMUM ENCLOSING RECTANGLE ON FIGURE
%         xbar = objProperties(i).Centroid(1);
%         ybar = objProperties(i).Centroid(2);
% 
%         a = objProperties(i).MajorAxisLength/2;
%         b = objProperties(i).MinorAxisLength/2;
% 
%         theta = pi*objProperties(i).Orientation/180;
%         R = [ cos(theta)   sin(theta)
%              -sin(theta)   cos(theta)];
% 
%         xy = [a*cosphi; b*sinphi];
%         xy = R*xy;
% 
%         x = xy(1,:) + xbar;
%         y = xy(2,:) + ybar;
% 
%         plot(x,y,'g','LineWidth',1);
        
        % OVERLAYS BOUNDING BOX ON FIGURE, UNCOMMENT BELOW TO PLOT CENTROID
        % plot(centroids(:,1), centroids(:,2), 'ro');
        rectangle('Position', objProperties(i).BoundingBox,'edgecolor','g');
    end
    hold off
    
    disp(' ------------------------------------------------------------------------------------------------------------------------- ');
    
    % SAVE OUTPUT IMAGE (CURRENT FIGURE) AS PNG IMAGE FILE
    saveas(gcf, imageOutName{1});
end