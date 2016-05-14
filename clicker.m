function clicker( path )
    % path = path of transformed images
    % source_path = path of original database
    % dest_path = path of target folder where the images will be copied

    FILE_ENDINGS = {'png', 'jpg', 'bmp'};
    len = 0;
    root = path;
    
    % first run for allocation
    listing = dir(root);
    for i = 1:numel(listing)
        if (listing(i).isdir && ~strcmp(listing(i).name, '.') && ~strcmp(listing(i).name, '..'))
            f = dir(strcat(root, listing(i).name, '/*'));
            f = f(~cellfun(@isempty,regexpi({f.name}, ['.*(', strjoin(FILE_ENDINGS, '|'), ')'])));
            len = len + numel(f);
        end
    end
    
    
    
    inx = 1;
    for i = 1:numel(listing)
        if (listing(i).isdir && ~strcmp(listing(i).name, '.') && ~strcmp(listing(i).name, '..'))
            person_id = listing(i).name;
            inner_dir = strcat(root, person_id, '/');
            listing_f = dir(strcat(inner_dir, '*'));
            listing_f = listing_f(~cellfun(@isempty,regexpi({listing_f.name}, ['.*(', strjoin(FILE_ENDINGS, '|'), ')'])));
            
            disp([num2str(i), ' ==================== ', person_id]);
            for j = 1:numel(listing_f)
                
                fname = strcat(inner_dir, listing_f(j).name);
                
                figure(1);
                imshow(fname);                
                
                [x,y] = ginput(1);
                save(strcat(fname, '.point.mat'), 'x', 'y');
            end
        end
    end


end

