function getBinaryMask(image)
    I = uint8(imread(image));
    BW = roipoly(I);
    figure(1);
    subplot(1,3,1);
    imshow(I);
%     BW = load('mask_left.mat');
%     BW = BW.BW;
    subplot(1,3,2);
    imshow(BW);
    cropped_I = I .*uint8(BW);
    subplot(1,3,3);
    imshow(cropped_I);
    save('mask_left.mat', 'BW');
end