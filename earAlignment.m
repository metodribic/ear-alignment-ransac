function [im2_, output_data, H] = earAlignment(im1, im2, current_data, side)
% SIFT_MOSAIC Demonstrates matching two images using SIFT and RANSAC
%
%   SIFT_MOSAIC demonstrates matching two images based on SIFT
%   features and RANSAC and computing their mosaic.
%
%   SIFT_MOSAIC by itself runs the algorithm on two standard test
%   images. Use SIFT_MOSAIC(IM1,IM2) to compute the mosaic of two
%   custom images IM1 and IM2.

% AUTORIGHTS

% --------------------------------------------------------------------
%                                                vlFeat initialization
% --------------------------------------------------------------------

% start vlFeat library if it is not already installed
if ~exist('vl_version', 'file')
    run('vlfeat-0.9.20/toolbox/vl_setup');
end

% --------------------------------------------------------------------
%                                                            Prepocess
% --------------------------------------------------------------------

% if number of input aruguments are 0, load pictures here
% original_im1 = im1;
original_im2 = im2;

% a: variable for buttons on GUI
global a
a = 0;

% figure(1) ; clf ;


% get sizes of pictures
% [~, ~, ch1] = size(original_im1);
[~, ~, ch2] = size(original_im2);

% resize
% im1 = imresize(original_im1, [100 NaN]);
im2 = imresize(original_im2, [100 NaN], 'bilinear');

% [height_im2, width_im2, ~] = size(im2);

% make single
im1 = im2single(im1) ;
im2 = im2single(im2) ;

% make grayscale
% if ch1 == 3
%     im1g = rgb2gray(im1);
% else
%     im1g = im1;
% end

if ch2 == 3
    im2g = rgb2gray(im2);
else
    im2g = im2;
end

% normalize histograms
% im1g = histeq(im1g);
im2g = histeq(im2g);

% --------------------------------------------------------------------
%                                                         SIFT matches
% --------------------------------------------------------------------

if strcmp(side, 'l') == 1
    feature = load('Average_ear/perfect_left_features.mat');
elseif strcmp(side, 'r') == 1
    feature = load('Average_ear/perfect_right_features.mat');
end

f1 = feature.tmp.f;
d1 = feature.tmp.d;

%     [f1,d1] = vl_sift(im1g, 'PeakThresh', 0, 'edgethresh', 1000, 'NormThresh', 2, 'Levels', 200, 'Magnif', 5);
[f2,d2] = vl_sift(im2g, 'PeakThresh', 0, 'edgethresh', 1000, 'NormThresh', 2, 'Levels', 200, 'Magnif', 5);


[matches, scores] = vl_ubcmatch(d1,d2, 0.9) ;

numMatches = size(matches,2) ;

X1 = f1(1:2,matches(1,:)) ; X1(3,:) = 1 ;
X2 = f2(1:2,matches(2,:)) ; X2(3,:) = 1 ;


% while a == 0


    % --------------------------------------------------------------------
    %                                         RANSAC with homography model
    % --------------------------------------------------------------------
while a < 3
    clear H score ok ;
    
    switch a
       case 0
          to = 5000;
       case 1
          to = 10000;
       case 2
          to = 25000;
    end
    
    disp(['Threshold: ',num2str(to)]);
    for t = 1:to
      % estimate homograpyh - take random 4 points
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

    % MOVED TO BOTTOM BECAUSE OF GUI
    % function err = residual(H)
    %  u = H(1) * X1(1,ok) + H(4) * X1(2,ok) + H(7) ;
    %  v = H(2) * X1(1,ok) + H(5) * X1(2,ok) + H(8) ;
    %  d = H(3) * X1(1,ok) + H(6) * X1(2,ok) + 1 ;
    %  du = X2(1,ok) - u ./ d ;
    %  dv = X2(2,ok) - v ./ d ;
    %  err = sum(du.*du + dv.*dv) ;
    % end

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

%     dh1 = max(size(im2,1)-size(im1,1),0) ;
%     dh2 = max(size(im1,1)-size(im2,1),0) ;
%     
%     figure(3) ; clf ;
%     subplot(2,1,1) ;
%     imagesc([padarray(im1,dh1,'post') padarray(im2,dh2,'post')]) ;
%     o = size(im1,2) ;
%     line([f1(1,matches(1,:));f2(1,matches(2,:))+o], ...
%          [f1(2,matches(1,:));f2(2,matches(2,:))]) ;
%     title(sprintf('%d tentative matches', numMatches)) ;
%     axis image off ;
%     
%     subplot(2,1,2) ;
%     imagesc([padarray(im1,dh1,'post') padarray(im2,dh2,'post')]) ;
%     o = size(im1,2) ;
%     line([f1(1,matches(1,ok));f2(1,matches(2,ok))+o], ...
%          [f1(2,matches(1,ok));f2(2,matches(2,ok))]) ;
%     title(sprintf('%d (%.2f%%) inliner matches out of %d', ...
%                   sum(ok), ...
%                   100*sum(ok)/numMatches, ...
%                   numMatches)) ;
%     axis image off ;
%     
%     drawnow ;

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
    [im1_, jx, jy] = vl_imwbackward(im2double(im1),u,v) ;
    [h1,w1,~] = size(im2);
%     im2(round(h1/2), round(w1/2),:) = [0; 255; 0];
    z_ = H(3,1) * u + H(3,2) * v + H(3,3) ;
    u_ = (H(1,1) * u + H(1,2) * v + H(1,3)) ./ z_ ;
    v_ = (H(2,1) * u + H(2,2) * v + H(2,3)) ./ z_ ;
    [im2_, jx2, jy2] = vl_imwbackward(im2double(im2),u_,v_) ;

    %TODO: CE RABIS MOSAIC JE TUKI NEKI NAROBE, NO IDEA WHAT, RETURN TO
    % VERJETNO NEKI Z IM1G IN IM2F...
    %mass = ~isnan(im1_) + ~isnan(im2_) ;
    im1_(isnan(im1_)) = 0 ;
    im2_(isnan(im2_)) = 0 ;
    %mosaic = (im1_ + im2_) ./ mass ;
    
%     [pos1, pos2] = find(im2_(:,:,1)<50 & im2_(:,:,2)>100 & im2_(:,:,3)<50);
    
    % calculate new Center
%     figure(2);
%     subplot(1,2,1); imshow(im2); hold on
%     plot(w1/2, h1/2,'g.','MarkerSize',30)
% %     center = [h1/2; w1/2; 1];
% %     center = inv(H) * center;
% %     center = center/center(3);
%     subplot(1,2,2); imshow(im2_); hold on
%     plot(pos2, pos1,'r.','MarkerSize',30)
%     

    % --------------------------------------------------------------------
    %                                        Plot start images and results
    % --------------------------------------------------------------------

%     figure(2) ; clf ;
%     subplot(2,3,1);
%     imagesc(im1_) ; axis image off ; 
%     title(['Original image (resized to 100x100 from ', num2str(width_im1), 'x', num2str(height_im1), ')']);
%     
%     subplot(2,3,2);
%     imagesc(original_im2) ; axis image off ; 
%     title('Distoreted image');
%     
%     subplot(2,3,3);
%     imagesc(im2) ; axis image off ; 
%     title(['Distoreted image (resized to ',num2str(height_im2),'x',num2str(width_im2), ...
%            ' from ', num2str(height_original_im2), 'x', num2str(width_original_im2), ')']);
%     
%     subplot(2,3,4);
%     imagesc(im2_) ; axis image off; 
%     title('Aligned image');
%     
%      subplot(2,3,5);
%      imagesc(mosaic) ; axis image off ;
%      title('Mosaic') ;
%      
%      time = toc;
%      disp(['Magic happend in ', num2str(time), ' seconds!']);

    % --------------------------------------------------------------------
    %                                                                  GUI
    % --------------------------------------------------------------------
    figure(3); clf;
    subplot(1,2,1);
    imagesc(original_im2) ; axis image off ; 
    title('Distoreted image');

    sub1 = subplot(1,2,2);
    imagesc(im2_) ; axis image off; hold on 
    title('Aligned image');
    
    % compute new tragus
%     [him2, wim2, ~] = size(im2);
%     [horg2, worg2, ~] = size(original_im2);
%     
%     oldTragus = struct();
%     oldTragus.x = current_data.x;
%     oldTragus.y = current_data.y;
%     
%     newTragus.x = (oldTragus.x * him2)/ horg2;
%     newTragus.y = (oldTragus.y * wim2)/ worg2;
%     newTragus = [newTragus.x; newTragus.y; 1];
%     
%     newTragus = H*newTragus;
%     newTragus = newTragus/newTragus(3);
%     plot(newTragus(1), newTragus(2),'r.','MarkerSize',30)
    
    
    % check if transformation was ok
    % it is ok if score is above 45%
    % it is also ok if score is abobe 40% after 25000 iterations in RANSAC
    percent = 100*sum(ok)/numMatches;
    if percent < 45
        a = a + 1;
        if a == 3
            output_data = 'fail';
            break;
        end
    else
        output_data = 'ok';
        break; 
    end
    
    
    
    
end
% 
%     % BUTTONS
%     btn1 = uicontrol('Style', 'pushbutton', 'String', 'FAIL',...
%         'Position', [400 20 50 20],...
%         'Callback', @isFailed);
% 
%     btn2 = uicontrol('Style', 'pushbutton', 'String', 'OK',...
%         'Position', [500 20 50 20],...
%         'Callback', @isOk);
% 
%     btn3 = uicontrol('Style', 'pushbutton', 'String', 'ORG',...
%         'Position', [120 20 50 20],...
%         'Callback', @isOrg); 
% 
%     btn4 = uicontrol('Style', 'pushbutton', 'String', 'SKIP',...
%         'Position', [20 20 50 20],...
%         'Callback', @skip); 
% 
%     % wait me to decide
%     uiwait;
    %clear subplot
%     clf('reset');
% end % end while

% % set a = 1 if OK button is pressed
% function isFailed(hObject, eventdata, ~)
%     disp('Aligning again...');
%     uiresume;
% end
% 
% % set a = 1 if OK button is pressed
% function isOk(hObject, eventdata, ~)
%     a = 1;
%     uiresume;
%     disp('Saving aligned image');
% end
% 
% % set a = 2 if ORG button is pressed
% function isOrg(hObject, eventdata, ~)
%     a = 2;
%     uiresume;
%     disp('Saving original image')
% end
% 
% % set a = 1 if SKIP button is pressed
% function skip(hObject, eventdata, ~)
%     a = 3;
%     uiresume;
%     disp('Skiping this image.');
% end
% 
% % return data and image, depending on value of a
% if a == 2
%     im2_ = im2;
%     output_data = 'ok';
% end
% 
% if a == 1
%     output_data = 'ok';
% end
% 
% if a == 0 || a == 3
%     output_data = 'fail';
% end

% function for correcting H matrix
function err = residual(H)
 u = H(1) * X1(1,ok) + H(4) * X1(2,ok) + H(7) ;
 v = H(2) * X1(1,ok) + H(5) * X1(2,ok) + H(8) ;
 d = H(3) * X1(1,ok) + H(6) * X1(2,ok) + 1 ;
 du = X2(1,ok) - u ./ d ;
 dv = X2(2,ok) - v ./ d ;
 err = sum(du.*du + dv.*dv) ;
end

if nargout == 0, clear mosaic ; end
end



