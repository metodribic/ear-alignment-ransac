%%
% find best ear of one person
%%

function best_fit = get_best_ear(path, side)

% if nargin == 0
%     path = 'databases/awe/030/';
% end

% --------------------------------------------------------------------
%                                                read annotations.json
% --------------------------------------------------------------------

    fname = strcat(path, 'annotations.json');
    fid = fopen(fname);
    raw = fread(fid,inf);
    str = char(raw');
    fclose(fid);
    data = JSON.parse(str);

% --------------------------------------------------------------------
%                                                      find best match
% --------------------------------------------------------------------
    % load first one as best fit
    best_fit = data.data.s01;
    for i = 2:10
        if i < 10
            command = strcat('data.data.s0',num2str(i));
        else
            command = strcat('data.data.s',num2str(i));
        end
        current_data = eval(command);
        
        if strcmp(current_data.d, side) == 1
            %check all parameters accessories, overlap, hPitch, hYaw, hRol, 
            if best_fit.accessories >= current_data.accessories
                if best_fit.overlap >= current_data.overlap
                    if best_fit.hYaw == current_data.hYaw
                        % check the resolution of picture
                        if best_fit.h < current_data.h && best_fit.w < current_data.w
                            best_fit = current_data;
                        end
                    else
                        if best_fit.hYaw > current_data.hYaw
                            best_fit = current_data;
                        end
                    end
                end
            end
        end
    end
end
