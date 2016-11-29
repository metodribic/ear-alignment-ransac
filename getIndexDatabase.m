% from database, make new one, index image from 0 to n and make mapping
% list containing pairs: original_image > index

function getIndexDatabase()

    % open list file
    listFileID = fopen('list.txt','w');
    
    % which side you are aligning (left or right)
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
        

%         % get dir data
%         fname = strcat(path, 'annotations.json');
%         fid = fopen(fname);
%         raw = fread(fid,inf);
%         str = char(raw');
%         fclose(fid);
%         dir_data = JSON.parse(str);
        
        
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
            

            % TODO: save image and make list

        end
    end
    
    test_image = double(avg_image)./counter;
    test_image = ceil(test_image);
    figure(1); clf;
    imshow(uint8(test_image));
    disp(counter);
    imwrite(uint8(test_image), 'perfect_right.png')
    
    % close list file
    fclose(listFileID);
    
end