function magic()

% --------------------------------------------------------------------
%                                       INPUT + HISTOGRAM NORMALZATION
% --------------------------------------------------------------------
    % input images
    original  = rgb2gray(imread('databases/awe/028/10.png'));
    distorted = rgb2gray(imread('databases/awe/028/03.png'));


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
    X1 = feature1(1:2,matches(1,:)) ; X1(3,:) = 1 ;
    X2 = feature2(1:2,matches(2,:)) ; X2(3,:) = 1 ;
%     X1 = double(X1)';
%     X2 = double(X2)';
    
    % Display matched features
    figure(1);
    subplot(2, 3, 3); showMatchedFeatures(original,distorted,X1,X2);
    title('Matched SIFT points,including outliers');

% --------------------------------------------------------------------
%                                                               RANSAC
% --------------------------------------------------------------------
        clear H score ok ;
        for t = 1:100
          % estimate homograpyh
          subset = vl_colsubset(1:numMatches, 4) ;
          A = [] ;
          for i = subset
            A = cat(1, A, kron(X1(:,i)', vl_hat(X2(:,i)))) ;
          end
          [U,S,V] = svd(A) ;
          H{t} = reshape(V(:,9),3,3) ;

          % score homography
          X2_ = H{t} * X1 ;
          du = X2_(1,:)./X2_(3,:) - X2(1,:)./X2(3,:) ;
          dv = X2_(2,:)./X2_(3,:) - X2(2,:)./X2(3,:) ;
          ok{t} = (du.*du + dv.*dv) < 6*6 ;
          score(t) = sum(ok{t}) ;
        end

        [score, best] = max(score) ;
        H = H{best} ;
        ok = ok{best} ;


%     coef.minPtNum = 4;
%     coef.iterNum = 30;
%     coef.thDist = 4;
%     coef.thInlrRatio = .1;
%     [H corrPtIdx] = ransac1(X1,X2,coef,@solveHomo,@calcDist);

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

function d = calcDist(H,pts1,pts2)
%	Project PTS1 to PTS3 using H, then calcultate the distances between
%	PTS2 and PTS3

n = size(pts1,2);
pts3 = H*[pts1;ones(1,n)];
pts3 = pts3(1:2,:)./repmat(pts3(3,:),2,1);
d = sum((pts2-pts3).^2,1);

end

