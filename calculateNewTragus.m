function calculateNewTragus(path)
        % path = path of transformed images

    json_path = 'databases/awe/';
    root = path;
    listing = dir(root);
    for i = 1:numel(listing)
        if (listing(i).isdir && ~strcmp(listing(i).name, '.') && ~strcmp(listing(i).name, '..'))
            person_id = listing(i).name;
            inner_dir = strcat(root, person_id, '/');
            listing_f = dir(strcat(inner_dir, '*.png'));
            
            for j = 1:numel(listing_f)
                
                fname = strcat(inner_dir, listing_f(j).name);
                disp(['  ',fname]);
                fpoint = strcat(fname, '.point.mat');
                
                % preberi sliko
                I = imread(fname);
                I = rgb2gray(I);

                % preberi tragus od te slike
                i_tragus = load(fpoint); % this goes to x, y
                i_tragus = [int16(round(i_tragus.x)), int16(round(i_tragus.y))];

                
                
            end
        end
    end


end