function start()
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
        
        % strukturiraj ime slik
        for j = 1:10
            %prva slika - poravnavamo na njo
            if j == 1
                if j < 10
                    name = strcat('0', sprintf('%01d',j));
                else
                    name = int2str(j);
                end
                name = strcat(name, '.png');
                original = strcat(path,name);
            % ?e ni prava, preberi j-to sliko
            else
                if j < 10
                name = strcat('0', sprintf('%01d',j));
	            else
	                name = int2str(j);
                end
	            distorted = strcat(path,strcat(name, '.png'));
                %disp([original, ' ', distorted]);
                magic(original, distorted);
            end
            
        end
    end
end