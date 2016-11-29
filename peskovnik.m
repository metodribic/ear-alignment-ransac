function peskovnik()


    index = 0;
    full = 0;
    side = 'l';
%     Is = zeros(100,100,520);

    % iterate over all directories
    for i=1:100
        
        % create path for reading dir        
        path = 'databases/awe/';
        result_dir = 'results/';
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
        mkdir([result_dir, prefix]);
        

        % get dir data
        fname = strcat(path, 'annotations.json');
        fid = fopen(fname);
        raw = fread(fid,inf);
        str = char(raw');
        fclose(fid);
        dir_data = JSON.parse(str);
        
        st_oseb = 0;
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
            result_path = [result_dir,prefix, name];
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
            
          if current_data.hRoll < 2 && current_data.hRoll > - 2&& current_data.hYaw < 2
            index = index +1;
            full = 1;
            disp(image_path);
            I = imread(image_path);
%             figure(1); imshow(I);
            I = imresize(I, [100 100]);
            if size(I, 3) > 1
                I = rgb2gray(I);
            end
            imwrite(I, result_path);
%             Is(:,:,i+j) = I;
          end
            
        end
        if(full == 0)
            rmdir([result_dir, prefix]);
        end
    end
    disp(index);



end

