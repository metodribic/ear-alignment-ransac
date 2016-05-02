function average_ear()


    
    for i=1:100
        path = 'databases/awe/';
        prefix = '';
        %strukturiraj ustrezen prefix za branje baze
        if i <10
            prefix = strcat('0', sprintf('%02d',i));
        elseif i<100
            prefix = strcat('0', sprintf('%01d',i));
        else
            prefix = int2str(i);
        end
        prefix = strcat(prefix, '/');
        path = strcat(path, prefix);
        
        
        for j = 1:10
            % strukturiraj ime slik
            if j < 10
            name = strcat('0', sprintf('%01d',j));
            else
                name = int2str(j);
            end
            % sestavi ime
            image_path = strcat(path,strcat(name, '.png'));
            % preberi sliko
            image = uint32(imread(image_path));
            % ?e ni ?rnobela, jo spremeni
            [~,~,color] = size(image);
            if color ~= 1
                image = rgb2gray(image);
            end
            % vsi na 100x100
            image = imresize(image, [100 100]);
            if i == 1 && j == 1
                avg_image = image;
            else
                avg_image = avg_image + image;
            end
            
            %disp(image_path);
    
            %imshow(image);
        end
    end

    test_image = double(avg_image)./1000;
    test_image = ceil(test_image);
    figure(1); clf;
    imshow(uint8(test_image));
end