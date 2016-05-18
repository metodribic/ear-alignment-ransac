function peskovnik(im1)
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
% if ~exist('vl_version', 'file')
%     run('vlfeat-0.9.20/toolbox/vl_setup');
% end
% 
% % --------------------------------------------------------------------
% %                                                            Prepocess
% % --------------------------------------------------------------------
% 
% % if number of input aruguments are 0, load pictures here
% original_im1 = im1;
% 
% im1 = imresize(original_im1, [100 NaN]);
% 
% [~, ~, ch1] = size(original_im1);
% 
% % make single
% im1 = im2single(im1) ;
% 
% 
% % make grayscale
% if ch1 == 3
%     im1g = rgb2gray(im1);
% else
%     im1g = im1;
% end
% 
% % normalize histograms
% im1g = histeq(im1g);
% 
% 
% % --------------------------------------------------------------------
% %                                                         SIFT matches
% % --------------------------------------------------------------------
% [f1,d1] = vl_sift(im1g, 'PeakThresh', 0, 'edgethresh', 1000, 'NormThresh', 2, 'Levels', 200, 'Magnif', 5);
% tmp = struct();
% tmp.f = f1;
% tmp.d = d1;
% 
% save('perfect_right_features.mat', 'tmp');



    index = 0;
    side = 'r'

    if ~exist('results', 'dir')
        mkdir('results');
    end
    
    % open file for list of aligned images
    fileID = fopen('list.txt','w');

    
    % iterate over all directories
    for i=1:100
        
        % create path for reading dir        
        path = 'databases/awe/';
        prefix = '';
        
        % make prefix for reading database (001, 002, ...)
        if i <10
            prefix = strcat('0', sprintf('%02d',i));
        elseif i<100
            prefix = strcat('0', sprintf('%01d',i));
        else
            prefix = int2str(i);
        end
        
        % get full path of direcotry
        prefix = strcat(prefix, '/');
        path = strcat(path, prefix);
        

        % get dir data
        fname = strcat(path, 'annotations.json');
        fid = fopen(fname);
        raw = fread(fid,inf);
        str = char(raw');
        fclose(fid);
        dir_data = JSON.parse(str);
        
        % iterate over all images in dir
        for j = 1:10
            
            % get name of picture
            if j < 10
            name = strcat('0', sprintf('%01d',j));
            else
                name = int2str(j);
            end
            
            name_index = name;
            name = strcat(name, '.png');
            
            image_path = strcat(path,name);
            
            %check the side
            if j < 10
                command = strcat('dir_data.data.s0',num2str(j));
            else
                command = strcat('dir_data.data.s',num2str(j));
            end
            current_data = eval(command);
            
            % skip if side is not right
            if ~strcmp(current_data.d,side)
                continue;
            end
                if current_data.hRoll == 0 && current_data.hYaw == 0
                    index = index +1;
                    disp(image_path);
                end
            
                
        end
    end
    index
end

