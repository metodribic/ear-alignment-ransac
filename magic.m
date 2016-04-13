function magic()

% --------------------------------------------------------------------
%                                       INPUT + HISTOGRAM NORMALZATION
% --------------------------------------------------------------------
    % input images
    original  = rgb2gray(imread('1/02.png'));
    distorted = rgb2gray(imread('1/06.png'));
    
    original  = rgb2gray(imread('2/09.png'));
    distorted = rgb2gray(imread('2/10.png'));
 
%     original  = rgb2gray(imread('3/03.png'));
%     distorted = rgb2gray(imread('3/10.png'));

    original = histeq(original);
    distorted = histeq(distorted);

% --------------------------------------------------------------------
%                                                                 SIFT
% --------------------------------------------------------------------

    
    % show original and distorted picture
    figure(1);
    subplot(2, 3, 1); imshow(uint8(original));  title('Original image');
    figure(1);
    subplot(2, 3, 2); imshow(uint8(distorted)); title('Distorted image'); 
    

    % Extract features and descriptors
    [feature1,descriptor1] = vl_sift(single(original), 'PeakThresh', 0, 'edgethresh', 100);
    [feature2,descriptor2] = vl_sift(single(distorted), 'PeakThresh', 0, 'edgethresh', 100);
    
    % Matches the two sets of SIFT descriptors descriptor1 and descriptor2.
    [matches, scores] = vl_ubcmatch(descriptor1,descriptor2); 
    
    % Number of matches
    numMatches = size(matches,2);
    disp(['Number of matches: ',num2str(numMatches)]);

    % Get match pairs matrix
    X1 = feature1(1:2,matches(1,:)) ; %X1(3,:) = 1 ;
    X2 = feature2(1:2,matches(2,:)) ; %X2(3,:) = 1 ;
    X1 = double(X1)';
    X2 = double(X2)';
    
    % Display matched features
    figure(1);
    subplot(2, 3, 3); showMatchedFeatures(original,distorted,X1,X2);
    title('Matched SIFT points,including outliers');

% --------------------------------------------------------------------
%                                                               RANSAC
% --------------------------------------------------------------------
    

    ransacCoef = struct('minPtNum', 4,'iterNum',10,'thDist',50,'thInlrRatio', 200);

    % Exclude the outliers, and compute the transformation matrix.
    [tform,inlierPtsOriginal,inlierPtsDistorted, status] = ...
        estimateGeometricTransform(X1,X2,'Projective', 'Confidence', 99);
    
    % Status must be 0 to complete transformation
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

