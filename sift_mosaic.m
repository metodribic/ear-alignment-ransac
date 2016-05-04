function mosaic = sift_mosaic(im1, im2)
% SIFT_MOSAIC Demonstrates matching two images using SIFT and RANSAC
%
%   SIFT_MOSAIC demonstrates matching two images based on SIFT
%   features and RANSAC and computing their mosaic.
%
%   SIFT_MOSAIC by itself runs the algorithm on two standard test
%   images. Use SIFT_MOSAIC(IM1,IM2) to compute the mosaic of two
%   custom images IM1 and IM2.

% AUTORIGHTS

% start vlFeat library
%run('../vlfeat-0.9.20/toolbox/vl_setup');

% --------------------------------------------------------------------
%                                                            Prepocess
% --------------------------------------------------------------------
disp('Magic is happening ...');
tic
% if number of input aruguments are 0, load pictures here
if nargin == 0
    original_im1 = imread('databases/awe/028/10.png') ;
    original_im2 = imread('databases/awe/028/08.png') ;
  
    % get sizes of pictures
    [width_im1, height_im1, ~] = size(original_im1);
    [width_im2, height_im2, ~] = size(original_im2);
  
    im1 = imresize(original_im1, [100 100]);
    im2 = imresize(original_im2, [100 100]);
    
end




% make single
im1 = im2single(im1) ;
im2 = im2single(im2) ;

% make grayscale
im1g = rgb2gray(im1);
im2g = rgb2gray(im2);
im1g = histeq(im1g);
im2g = histeq(im2g);

% --------------------------------------------------------------------
%                                                         SIFT matches
% --------------------------------------------------------------------

[f1,d1] = vl_sift(im1g, 'PeakThresh', 0, 'edgethresh', 1000, 'NormThresh', 2, 'Levels', 200, 'Magnif', 5);
[f2,d2] = vl_sift(im2g, 'PeakThresh', 0, 'edgethresh', 1000, 'NormThresh', 2, 'Levels', 200, 'Magnif', 5);

[matches, scores] = vl_ubcmatch(d1,d2, 0.9) ;

numMatches = size(matches,2) ;

X1 = f1(1:2,matches(1,:)) ; X1(3,:) = 1 ;
X2 = f2(1:2,matches(2,:)) ; X2(3,:) = 1 ;

% --------------------------------------------------------------------
%                                         RANSAC with homography model
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

% --------------------------------------------------------------------
%                                                  Optional refinement 
% --------------------------------------------------------------------

function err = residual(H)
 u = H(1) * X1(1,ok) + H(4) * X1(2,ok) + H(7) ;
 v = H(2) * X1(1,ok) + H(5) * X1(2,ok) + H(8) ;
 d = H(3) * X1(1,ok) + H(6) * X1(2,ok) + 1 ;
 du = X2(1,ok) - u ./ d ;
 dv = X2(2,ok) - v ./ d ;
 err = sum(du.*du + dv.*dv) ;
end

% TODO: Check the exist return value, default was 2!
if exist('fminsearch') == 6
  H = H / H(3,3) ;
  opts = optimset('Display', 'none', 'TolFun', 1e-8, 'TolX', 1e-8) ;
  H(1:8) = fminsearch(@residual, H(1:8)', opts) ;
else
  warning('Refinement disabled as fminsearch was not found.') ;
end

% --------------------------------------------------------------------
%                                                         Show matches
% --------------------------------------------------------------------

dh1 = max(size(im2,1)-size(im1,1),0) ;
dh2 = max(size(im1,1)-size(im2,1),0) ;

figure(1) ; clf ;
subplot(2,1,1) ;
imagesc([padarray(im1,dh1,'post') padarray(im2,dh2,'post')]) ;
o = size(im1,2) ;
line([f1(1,matches(1,:));f2(1,matches(2,:))+o], ...
     [f1(2,matches(1,:));f2(2,matches(2,:))]) ;
title(sprintf('%d tentative matches', numMatches)) ;
axis image off ;

subplot(2,1,2) ;
imagesc([padarray(im1,dh1,'post') padarray(im2,dh2,'post')]) ;
o = size(im1,2) ;
line([f1(1,matches(1,ok));f2(1,matches(2,ok))+o], ...
     [f1(2,matches(1,ok));f2(2,matches(2,ok))]) ;
title(sprintf('%d (%.2f%%) inliner matches out of %d', ...
              sum(ok), ...
              100*sum(ok)/numMatches, ...
              numMatches)) ;
axis image off ;

drawnow ;

% --------------------------------------------------------------------
%                                                               Mosaic
% --------------------------------------------------------------------

box2 = [1  size(im2,2) size(im2,2)  1 ;
        1  1           size(im2,1)  size(im2,1) ;
        1  1           1            1 ] ;
box2_ = inv(H) * box2 ;
box2_(1,:) = box2_(1,:) ./ box2_(3,:) ;
box2_(2,:) = box2_(2,:) ./ box2_(3,:) ;
ur = min([1 box2_(1,:)]):max([size(im1,2) box2_(1,:)]) ;
vr = min([1 box2_(2,:)]):max([size(im1,1) box2_(2,:)]) ;

[u,v] = meshgrid(ur,vr) ;
im1_ = vl_imwbackward(im2double(im1),u,v) ;

z_ = H(3,1) * u + H(3,2) * v + H(3,3) ;
u_ = (H(1,1) * u + H(1,2) * v + H(1,3)) ./ z_ ;
v_ = (H(2,1) * u + H(2,2) * v + H(2,3)) ./ z_ ;
im2_ = vl_imwbackward(im2double(im2),u_,v_) ;

mass = ~isnan(im1_) + ~isnan(im2_) ;
im1_(isnan(im1_)) = 0 ;
im2_(isnan(im2_)) = 0 ;
mosaic = (im1_ + im2_) ./ mass ;

% plot start images and results
figure(2) ; clf ;
subplot(2,3,1);
imagesc(im1_) ; axis image off ; 
title(['Original image (resized to 100x100 from ', num2str(width_im1), 'x', num2str(height_im1), ')']);

subplot(2,3,2);
imagesc(original_im2) ; axis image off ; 
title('Distoreted image');

subplot(2,3,3);
imagesc(im2) ; axis image off ; 
title(['Distoreted image (resized to 100x100 from ', num2str(width_im2), 'x', num2str(height_im2), ')']);

subplot(2,3,4);
imagesc(im2_) ; axis image off; 
title('Aligned image');

subplot(2,3,5);
imagesc(mosaic) ; axis image off ;
title('Mosaic') ;

% check distorted image size and compre it to the original image
% [width_im2_, height_im2_, ~] = size(im2_);
% if width_im1*1.1 < width_im2_
%     disp('Transformation fails! (width)');
%     disp([height_im1, height_im2_]);
% elseif height_im1*1.1 < height_im2_
%     disp('Transformation fails! (height)');
%     disp([width_im1, width_im2_]);
% end
% disp([width_im2, width_im2_]);
% disp([height_im2, height_im2_]);

time = toc;
disp(['Magic happend in ', num2str(time), ' seconds!']);

if nargout == 0, clear mosaic ; end
end
