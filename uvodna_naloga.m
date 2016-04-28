% read picture
I = imread('autumn.tif');
I = imcrop(I, [0 0 200 200]);
 subplot(1,3,1); figure(1); imshow(I); axis on;
I = imrotate(I, 30);
% t = maketform('affine',[1 0 0; .5 1 0; 0 0 1]);
% I = imwarp(I,tform);
% show image
subplot(1,3,2); figure(1); imshow(I);axis on;
% get points from user input
% t1 = ginput(4)
t1 = [0 100; 175 0; 275 175; 100 275];
% square
% t2 = [0 0; 0 200; 200 200; 200 0];
t2 = [0 0; 200 0; 200 200; 0 200];



[tform,inlierPtsDistorted,inlierPtsOriginal, status] = estimateGeometricTransform(t1,t2,'projective');
%tform.T(1,1) = 1;
res = imwarp(I, tform);



subplot(1,3,3); figure(1); imshow(res); axis on;
% imshow(transformed_image);


% backup

% Build up the matrix P
% P = zeros(2*n,9);
% for i=1:n,
%   P(2*i-1,:) = [-x1(i), -y1(i), -1, 0, 0, 0, x1(i)*x2(i), y1(i)*x2(i), x2(i)];
%   P(2*i,:)   = [0, 0, 0, -x1(i), -y1(i), -1 x1(i)*y2(i), y1(i)*y2(i), y2(i)];
% end;

% matrix decomposition
%[~, ~, V] = svd(P);
%h = V(:,9) ./V(9,9);
% reshape to form a matrix
%H = reshape(h,3,3)';



%transf = affine2d([1 0 0; .5 1 0; 0 0 1]);
%transf = affine2d(H);
%transformed_image = imwarp(image, H);