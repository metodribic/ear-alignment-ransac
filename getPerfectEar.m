function getPerfectEar()

    % which side you are aligning (left or right)
    side = 'r';
    counter = 0;
        
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
            
            % get name of picture
            if j < 10
            name = strcat('0', sprintf('%01d',j));
            else
                name = int2str(j);
            end

            name = strcat(name, '.png');
            image_path = strcat(path,name);
            

            % --------------------------------------------------------------------
            %                                                      find best match
            % --------------------------------------------------------------------

            if strcmp(current_data.d, side) == 1
                %check all parameters accessories, overlap, hPitch, hYaw, hRol, 
                if current_data.accessories == 0 && current_data.overlap == 0 && current_data.hYaw == 0 && ...
                        current_data.hPitch == 0 && current_data.hRoll == 0
                    % preberi sliko
                    image = uint32(imread(image_path));
                    % ce ni crnobela, jo spremeni
                    [~,~,color] = size(image);
                    if color ~= 1
                        image = rgb2gray(image);
                    end
                    % vsi na 100xNaN
                    image = imresize(image, [100 100]);
                    if counter == 0
                        avg_image = image;
                        counter = counter +1;
                    else
                        avg_image = avg_image + image;
                        counter = counter +1;
                    end
                end
            end
        end
    end
    
    test_image = double(avg_image)./counter;
    test_image = ceil(test_image);
    figure(1); clf;
    imshow(uint8(test_image));
    disp(counter);
    imwrite(uint8(test_image), 'perfect_right.png')
    
end