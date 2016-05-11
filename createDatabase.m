function createDatabase(side)

    % which side you are aligning (left or right)
%     side = 'l';
    global current_data
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
        
        % create dir for this person
        if ~exist(strcat('results',prefix), 'dir')
            mkdir('results', prefix);
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
        
        % get best_ear and its coresponding data
%         best_ear_data = get_best_ear(path, side);
%         best_ear = imread(strcat(path,best_ear_data.file));
        
        % average ear test
        if strcmp(side, 'l') == 1
            best_ear = imread('perfect_left.png');
        else
            best_ear = imread('perfect_right.png');
        end
        
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
            
            % save and skip best_ear
%             if strcmp(name, best_ear_data.file)
%                 save_path = strcat('results/', prefix);
%                 imwrite(best_ear, fullfile(save_path, name))
%                 continue;
%             end
            
            % read image
            image = imread(image_path);
            
            % check if ear is alreay alligned
            if current_data.hYaw == 2
                disp(['Yaw too big, skipping ', prefix, name]);
                continue;
            elseif ~(current_data.accessories == 0 && current_data.overlap == 0 && current_data.hYaw == 0)
                disp(['Aligning ear ', prefix, name]);
                [alligned_image, output_data] = ear_alignment(best_ear, image);
            else
                [~,~,ch] = size(image);
                if ch ~= 1
                    disp([prefix, name, ' is alredy aligned! Saving...']);
                    alligned_image = image;
                    output_data = 'ok';
                end
            end
            
            % Save image
            if strcmp(output_data,'ok') == 1
                save_path = strcat('results/', prefix);
                imwrite(alligned_image, fullfile(save_path, name))
                fprintf(fileID, strcat(prefix, name, '\n'));
            end
                
        end
    end
    fclose(fileID);
end