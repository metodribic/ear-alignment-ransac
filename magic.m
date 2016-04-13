function magic()

    % input images
    original  = rgb2gray(imread('1/02.png'));
    distorted = rgb2gray(imread('1/06.png'));
    
    
    original  = rgb2gray(imread('2/09.png'));
    distorted = rgb2gray(imread('2/10.png'));

%     original  = rgb2gray(imread('3/03.png'));
%     distorted = rgb2gray(imread('3/10.png'));

    % show original and distorted picture
    figure(1);
    subplot(2, 3, 1); imshow(uint8(original));  title('Original image');
    figure(1);
    subplot(2, 3, 2); imshow(uint8(distorted)); title('Distorted image'); 
    
    
    % Xing Di SIFT - http://www.mathworks.com/matlabcentral/fileexchange/50319-sift-feature-extreaction
    [x_org, y_org] = SIFT_feature(original, 0.0095);
    [x_dist, y_dist] = SIFT_feature(distorted, 0.0095);
    ptsOriginal = [x_org; y_org]';
    ptsDistorted = [x_dist; y_dist]';
    
    [featuresOriginal,validPtsOriginal]   = extractFeatures(original, ptsOriginal, 'Method','Block');
    [featuresDistorted,validPtsDistorted] = extractFeatures(distorted,ptsDistorted, 'Method','Block');
%     disp('SIFT size:');
%     disp(size(featuresOriginal));
%     disp(size(featuresDistorted));
    

    
    % MATLAB SURF
%     ptsOriginal  = detectSURFFeatures(original,  'MetricThreshold', 0);
%     ptsDistorted = detectSURFFeatures(distorted, 'MetricThreshold', 0);
%     [featuresOriginal,validPtsOriginal]   = extractFeatures(original, ptsOriginal, 'Method','Block');
%     [featuresDistorted,validPtsDistorted] = extractFeatures(distorted,ptsDistorted, 'Method','Block');
%     disp('SURF size:');
%     disp(size(featuresOriginal));
%     disp(size(featuresDistorted));

 
     % match features
    index_pairs = matchFeatures(featuresOriginal,featuresDistorted, 'MatchThreshold', 90, 'Unique', true, 'Metric', 'SAD', 'MaxRatio', 1);
    matchedPtsOriginal  = validPtsOriginal(index_pairs(:,1),:);
    matchedPtsDistorted = validPtsDistorted(index_pairs(:,2),:);

     figure(1);
     subplot(2, 3, 3); showMatchedFeatures(original,distorted,matchedPtsOriginal,matchedPtsDistorted);
     title('Matched SURF points,including outliers');

    
    % Exclude the outliers, and compute the transformation matrix.
    [tform,inlierPtsDistorted,inlierPtsOriginal, status] = estimateGeometricTransform(matchedPtsDistorted,matchedPtsOriginal,'projective', 'Confidence', 99);
    
    if status == 0
        figure(1);
        subplot(2, 3, 4); showMatchedFeatures(original,distorted,inlierPtsOriginal,inlierPtsDistorted);
        title('Matched inlier points');

        % Recover the original image from the distorted image. 
        outputView = imref2d(size(original));
        Ir = imwarp(distorted,tform,'OutputView',outputView);
        figure(1);
        subplot(2, 3, 5); imshow(Ir); title('Recovered image'); axis on;
        imwrite(Ir, 'test1.png')
        %figure(2); imshow(Ir);
    elseif status == 1
        disp('Not enough matched points!')
    end
    
    
end

