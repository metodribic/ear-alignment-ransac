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

    % iterate over all images in dir
    for j = 1:10

        %check the side
        if j < 10
            command = strcat('dir_data.data.s0',num2str(j));
        else
            command = strcat('dir_data.data.s',num2str(j));
        end
        current_data = eval(command);


        % get name of picture
        if j < 10
        name = strcat('0', sprintf('%01d',j));
        else
            name = int2str(j);
        end

        name = strcat(name, '.png');
        image_path = strcat(path,name);


    end
end
