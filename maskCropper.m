function maskCropper(path, side)
    % path = path of transformed images
    % source_path = path of original database
    % dest_path = path of target folder where the images will be copied

    if strcmp(side, 'left')
        mask = load('../PERFECTEAR/mask_left.mat');
        m = mask.BW;
        maskT = load('../PERFECTEAR/tragus_perfect_left.mat');
        m_tragus =[round(maskT.tragus(1,1)), round(maskT.tragus(1,2))];
    else
        mask = load('../PERFECTEAR/mask_right.mat');
        m = mask.BW;
        maskT = load('../PERFECTEAR/tragus_perfect_right.mat');
        m_tragus =[ceil(maskT.tragus(1,1)), ceil(maskT.tragus(1,2))];
    end
    
    m_tragus = int16(m_tragus);
    
%     [hM, wM, ~] = size(m);
    
    root = path;
    listing = dir(root);
    for i = 1:numel(listing)
        if (listing(i).isdir && ~strcmp(listing(i).name, '.') && ~strcmp(listing(i).name, '..'))
            person_id = listing(i).name;
            inner_dir = strcat(root, person_id, '/');
            listing_f = dir(strcat(inner_dir, '*.png'));
            
            
             disp([num2str(i), ' ==================== ', person_id]);
            for j = 1:numel(listing_f)
                
                fname = strcat(inner_dir, listing_f(j).name);
                disp(['  ',fname]);
                fpoint = strcat(fname, '.point.mat');
                
                % preberi sliko
                I = imread(fname);
                I = rgb2gray(I);
%                 I = imresize(I, [100 NaN]);
%                 [hI, wI, ~] = size(I);
                % preberi tragus od te slike
                i_tragus = load(fpoint); % this goes to x, y
                i_tragus = [int16(round(i_tragus.x)), int16(round(i_tragus.y))];

                mdiffX1 = m_tragus(1);
                mdiffX2 = size(m, 2) - mdiffX1;
                mdiffY1 = m_tragus(2);
                mdiffY2 = size(m, 1) - mdiffY1;

                idiffX1 = i_tragus(1);
                idiffX2 = size(I, 2) - idiffX1;
                idiffY1 = i_tragus(2);
                idiffY2 = size(I, 1) - idiffY1;

                xD1 = int16(mdiffX1 - idiffX1);
                xD2 = int16(mdiffX2 - idiffX2);
                yD1 = int16(mdiffY1 - idiffY1);
                yD2 = int16(mdiffY2 - idiffY2);

                if (xD1 > 0)
                   I = [zeros(size(I, 1), xD1),I];
                elseif (xD1 < 0)
%                    m = [zeros(size(m, 1), abs(xD1)), m];
                   I = I(:, abs(xD1)+1:end);
                end
                
                if (xD2 > 0)
                   I = [I, zeros(size(I, 1), xD2)];
                elseif (xD2 < 0)
%                    m = [m, zeros(size(m, 1), abs(xD2))];
                   I = I(:, 1:end-abs(xD2));
                end

                if (yD1 > 0)
                   I = [zeros(yD1, size(I, 2));I];
                elseif (yD1 < 0)
%                    m = [zeros(abs(yD1), size(m, 2)); m];
                   I = I(abs(yD1)+1:end, :);
                end
                
                if (yD2 > 0)
                   I = [I; zeros(yD2, size(I, 2))];
                elseif (yD2 < 0)
%                    m = [m; zeros(abs(yD2), size(m, 2))];
                   I = I(1:end-abs(yD2), :);
                end
                
                m = uint8(m);
                hip = m .*I;
                imwrite(hip, fname);
                
%                 disp(size(hip));
                
            end
        end
    end
    
  
end

