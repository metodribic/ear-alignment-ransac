function createDatabase()

    % which side you are aligning (left or right)
    side = 'l';
    
    % iterate over all directories
    for i=1:100
        
% --------------------------------------------------------------------
%                                          create path for reading dir
% --------------------------------------------------------------------
        
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
        
% --------------------------------------------------------------------
%                                                         get dir data
% --------------------------------------------------------------------
        
        fname = strcat(path, 'annotations.json');
        fid = fopen(fname);
        raw = fread(fid,inf);
        str = char(raw');
        fclose(fid);
        dir_data = JSON.parse(str);
        
% --------------------------------------------------------------------
%                               get best_ear and its coresponding data
% --------------------------------------------------------------------

        best_ear_data = get_best_ear(path, side);
        best_ear = imread(strcat(path,best_ear_data.file));
        
% --------------------------------------------------------------------
%                                       iterate over all images in dir
% --------------------------------------------------------------------

        for j = 1:10
            
            %check the side
            if j < 10
                command = strcat('dir_data.data.s0',num2str(j));
            else
                command = strcat('dir_data.data.s',num2str(j));
            end
            current_data = eval(command);
            
            % skip this one if side is not right
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
            
            % skip best_ear
            if strcmp(name, best_ear_data.file)
                continue;
            end
            
            % read image
            image = imread(image_path);
            alligned_image = ear_alignment(best_ear, image);
            % TODO: Save image
            figure(1); imshow(alligned_image);
        end
    end
end