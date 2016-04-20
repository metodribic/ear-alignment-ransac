function magic(input_original, input_distorted)

    %[db, a] = awetcore_database_load();
    % input images
     original  = rgb2gray(imread(input_original));
     distorted = rgb2gray(imread(input_distorted));
%          
%     original  = rgb2gray(imread('2/09.png'));
%     distorted = rgb2gray(imread('2/10.png'));
% 
%     original  = rgb2gray(imread('3/03.png'));
%     distorted = rgb2gray(imread('3/10.png'));

%     original = histeq(original);
%     distorted = histeq(distorted);

    % show original and distorted picture
    figure(1);
    subplot(2, 3, 1); imshow(uint8(original));  title('Original image');
    figure(1);
    subplot(2, 3, 2); imshow(uint8(distorted)); title('Distorted image'); 
    
    fails = true;
    


        % Xing Di SIFT - http://www.mathworks.com/matlabcentral/fileexchange/50319-sift-feature-extreaction
        [x_org, y_org] = SIFT_feature(original, 0.0095);
        [x_dist, y_dist] = SIFT_feature(distorted, 0.0095);
        ptsOriginal = [x_org; y_org]';
        ptsDistorted = [x_dist; y_dist]';

        [featuresOriginal,validPtsOriginal]   = extractFeatures(original, ptsOriginal, 'Method','Block');
        [featuresDistorted,validPtsDistorted] = extractFeatures(distorted,ptsDistorted, 'Method','Block');
    try_index = 0;
    while fails==true &&  try_index < 10

         % match features
        index_pairs = matchFeatures(featuresOriginal,featuresDistorted, 'MatchThreshold', 90, 'Unique', true, 'Metric', 'SAD', 'MaxRatio', 1);
        matchedPtsOriginal  = validPtsOriginal(index_pairs(:,1),:);
        matchedPtsDistorted = validPtsDistorted(index_pairs(:,2),:);

         figure(1);
         subplot(2, 3, 3); showMatchedFeatures(original,distorted,matchedPtsOriginal,matchedPtsDistorted);
         title('Matched SURF points,including outliers');


        % Exclude the outliers, and compute the transformation matrix.
        [tform,inlierPtsDistorted,inlierPtsOriginal, status] = estimateGeometricTransform(matchedPtsOriginal, matchedPtsDistorted,'projective', 'Confidence', 99);

        if status == 0

            % check if esimated homography fails
            %tform.T
            if tform.T(end, 1) < 5 && tform.T(end, 1) > -5
                if tform.T(end, 2) < 5 && tform.T(end, 2) > -5
                    fails = false;
                end
            end

            if fails == false
                figure(1);
                subplot(2, 3, 4); showMatchedFeatures(original,distorted,inlierPtsOriginal,inlierPtsDistorted);
                title('Matched inlier points');

                % Recover the original image from the distorted image. 
                outputView = imref2d(size(distorted));
                Ir = imwarp(distorted,tform);
                figure(1);
                subplot(2, 3, 5); imshow(Ir); title('Recovered image'); axis on;
                result_path = strcat('results/',distorted(15:1:end));
                imwrite(Ir, result_path)
                break
                %figure(2); imshow(Ir);
            else
                disp('Esitmated homograpy fails!');
            end

        elseif status == 1
            disp('Not enough matched points!')
        end % if end
        try_index = try_index +1;
    end %while end
    
end

