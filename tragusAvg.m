% manually select where is the tragus on picture and save it!

function tragusAvg(image_path)
    I = imread(image_path);
    figure(1); clf;
    imshow(I);
    [x,y] = ginput(1);
    tragus = [x y];
    save('tragus_perfect_left.mat', 'tragus');
end