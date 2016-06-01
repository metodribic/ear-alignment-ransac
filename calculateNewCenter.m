function calculateNewCenter(path, org_path)
        % path = path of transformed images
        % org_path = path of original images

    root = path;
    listing = dir(root);
    for i = 1:numel(listing)
        if (listing(i).isdir && ~strcmp(listing(i).name, '.') && ~strcmp(listing(i).name, '..'))
            person_id = listing(i).name;
            inner_dir = strcat(root, person_id, '/');
            listing_f = dir(strcat(inner_dir, '*.png'));
            

            org_inner_dir = strcat(org_path, person_id, '/');

            
            for j = 1:numel(listing_f)
                org_fname = strcat(org_inner_dir, listing_f(j).name);
                
                fname = strcat(inner_dir, listing_f(j).name);
                disp(['  ',fname]);
                fpoint = strcat(fname(1:end-4), '_H.mat');
                
                % preberi sliko
                I = imread(fname);
                I = rgb2gray(I);
                
                org_I = imread(org_fname);
%                 org_I = rgb2gray(I);
                org_I = imresize(org_I, [100 NaN], 'bilinear');
                
                I_mat = strcat(fname(1:end-4), '.mat');
                transformed_I = load(I_mat);
                alligned_image = transformed_I.alligned_image;
                aligned_image = rgb2gray(alligned_image);
                
                % calculate new center
                H = load(fpoint);
                H = H.H;
                [h_org, w_org, ~] = size(org_I);
                [h_alligned, w_alligned, ~] = size(aligned_image);
                
                center = [h_org/2; w_org/2; 1];
               

                center = inv(H)*center;
                center = center./center(3);
                figure(1);
                
%                 subplot(1,2,1);imshow(org_I); hold on
%                 plot(size(org_I,2)/2, size(org_I,1)/2,'g.','MarkerSize',30)
%                 subplot(1,2,2);
                imshow(alligned_image); hold on
                plot(center(2), center(1),'r.','MarkerSize',30)
                plot(round(w_alligned/2), round(h_alligned/2),'b.','MarkerSize',30)
                
%                 tmp = aligned_image(1:round(center(2)), 1:round(center(1)))
%                 sum(tmp(round(center(2)),:)==0)
                
                

                
                
            end
        end
    end


end