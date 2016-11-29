% apply mask from perfect ear to the image
% image is image object (NOT PATH!)
% side = left or right
% tragus point = struct() contining x and y coordinates of tragus point

function applyBinaryMask(image, side)
    I = image;
%     I = rgb2gray(I);
    if strcmp(side,'left')
        BW = load('mask_left.mat');
        BW = BW.BW;
        maskTragus = load('tragus_perfect_left.mat');
    else
        BW = load('mask_right.mat');
        BW = BW.BW;
        maskTragus = load('tragus_perfect_right.mat');
    end
    
    % resize mask to fit input image
    BW = imresize(BW, [size(I, 1) NaN]);
    [hm,wm,~] = size(BW);
    [hi,wi,~] = size(I);
    if wi > wm
        diff = wi - wm;
        l = round(diff/2);
        r = floor(diff/2);
        mask = [zeros(hm, l) BW zeros(hm, r)];
        mask = uint8(mask);
    else
        diff = wm - wi;
        l = round(diff/2);
        r = floor(diff/2);
        mask = [zeros(hi, l) BW zeros(hi, r)];
        mask = uint8(mask);
    end
    
    
    
    r = I(:,:,1);
    g = I(:,:,2);
    b = I(:,:,3);
    r = r.*mask;
    g = g.*mask;
    b = b.*mask;
    cropped_I(:,:,1) = r;
    cropped_I(:,:,2) = g;
    cropped_I(:,:,3) = b;
    
    figure(1);
    subplot(1,2,1);
    imshow(I);
%     cropped_I = I .*uint8(maskPad);
    subplot(1,2,2);
    imshow(cropped_I);
    cropped_I_gray = rgb2gray(cropped_I);
%     save('cropped_I_gray.mat', 'cropped_I_gray')
end