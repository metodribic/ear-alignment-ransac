%this code is the Matlab implimentation of David G. Lowe, 
%"Distinctive image features from scale-invariant keypoints,"
%International Journal of Computer Vision, 60, 2 (2004), pp. 91-110.
%this code should be used only for academic research.
%any other useage of this code should not be allowed without Author agreement.
% if you have any problem or improvement idea about this code, please
% contact with Xing Di, Stevens Institution of Technology. xdi2@stevens.edu

function [rx, ry] =  SIFT_feature(image, input_threshold)
    %%initial image
    tic

    row=256;
    colum=256;
    %img=imread('02.png');
    img = image;
    img=imresize(img,[row,colum]);
    %img=rgb2gray(img);
    % img=histeq(img);
    img=im2double(img);
    origin=img;
    % img=medfilt2(img);

    %% Scale-Space Extrema Detection

    % original sigma and the number of actave can be modified. the larger
    % sigma0, the more quickly-smooth images
    sigma0=sqrt(2);
    octave=3;%6*sigma*k^(octave*level)<=min(m,n)/(2^(octave-2))
    level=3;
    D=cell(1,octave);
    for i=1:octave
    D(i)=mat2cell(zeros(row*2^(2-i)+2,colum*2^(2-i)+2,level),row*2^(2-i)+2,colum*2^(2-i)+2,level);
    end
    % first image in first octave is created by interpolating the original one.
    temp_img=kron(img,ones(2));
    temp_img=padarray(temp_img,[1,1],'replicate');
    figure(2)
    subplot(1,2,1);
    imshow(origin)
    %create the DoG pyramid.
    for i=1:octave
        temp_D=D{i};
        for j=1:level
            scale=sigma0*sqrt(2)^(1/level)^((i-1)*level+j);
            p=(level)*(i-1);
%             figure(1);
%             subplot(octave,level,p+j);
            f=fspecial('gaussian',[1,floor(6*scale)],scale);
            L1=temp_img;
            if(i==1&&j==1)
            L2=conv2(temp_img,f,'same');
            L2=conv2(L2,f','same');
            temp_D(:,:,j)=L2-L1;
%             imshow(uint8(255 * mat2gray(temp_D(:,:,j))));
            L1=L2;
            else
            L2=conv2(temp_img,f,'same');
            L2=conv2(L2,f','same');
            temp_D(:,:,j)=L2-L1;
            L1=L2;
            if(j==level)
                temp_img=L1(2:end-1,2:end-1);
            end
            imshow(uint8(255 * mat2gray(temp_D(:,:,j))));
            end
        end
        D{i}=temp_D;
        temp_img=temp_img(1:2:end,1:2:end);
        temp_img=padarray(temp_img,[1,1],'both','replicate');
    end
    %% Keypoint Localistaion
    % search each pixel in the DoG map to find the extreme point

    interval=level-1;
    number=0;
    for i=2:octave+1
        number=number+(2^(i-octave)*colum)*(2*row)*interval;
    end
    extrema=zeros(1,4*number);
    flag=1;
    for i=1:octave
        [m,n,~]=size(D{i});
        m=m-2;
        n=n-2;
        volume=m*n/(4^(i-1));
        for k=2:interval      
            for j=1:volume
                % starter=D{i}(x+1,y+1,k);
                x=ceil(j/n);
                y=mod(j-1,m)+1;
                sub=D{i}(x:x+2,y:y+2,k-1:k+1);
                large=max(max(max(sub)));
                little=min(min(min(sub)));
                if(large==D{i}(x+1,y+1,k))
                    temp=[i,k,j,1];
                    extrema(flag:(flag+3))=temp;
                    flag=flag+4;
                end
                if(little==D{i}(x+1,y+1,k))
                    temp=[i,k,j,-1];
                    extrema(flag:(flag+3))=temp;
                    flag=flag+4;
                end
            end
        end
    end
    idx= extrema==0;
    extrema(idx)=[];

    [m,n]=size(img);
    x=floor((extrema(3:4:end)-1)./(n./(2.^(extrema(1:4:end)-2))))+1;
    y=mod((extrema(3:4:end)-1),m./(2.^(extrema(1:4:end)-2)))+1;
    ry=y./2.^(octave-1-extrema(1:4:end));
    rx=x./2.^(octave-1-extrema(1:4:end));
    figure(2)
    subplot(1,2,2);
    imshow(origin)
    hold on
    plot(ry,rx,'r+');
    %% accurate keypoint localization 
    %eliminate the point with low contrast or poorly localised on an edge
    % x:|,y:-- x is for vertial and y is for horizontal
    % value comes from the paper.

    threshold=input_threshold;
    r=10;
    extr_volume=length(extrema)/4;
    [m,n]=size(img);
    secondorder_x=conv2([-1,1;-1,1],[-1,1;-1,1]);
    secondorder_y=conv2([-1,-1;1,1],[-1,-1;1,1]);
    for i=1:octave
        for j=1:level
            test=D{i}(:,:,j);
            temp=-1./conv2(test,secondorder_y,'same').*conv2(test,[-1,-1;1,1],'same');
            D{i}(:,:,j)=temp.*conv2(test',[-1,-1;1,1],'same')*0.5+test;
        end
    end
    for i=1:extr_volume
        x=floor((extrema(4*(i-1)+3)-1)/(n/(2^(extrema(4*(i-1)+1)-2))))+1;
        y=mod((extrema(4*(i-1)+3)-1),m/(2^(extrema(4*(i-1)+1)-2)))+1;
        rx=x+1;
        ry=y+1;
        rz=extrema(4*(i-1)+2);
        z=D{extrema(4*(i-1)+1)}(rx,ry,rz);
        if(abs(z)<threshold)
            extrema(4*(i-1)+4)=0;
        end
    end
    idx=find(extrema==0);
    idx=[idx,idx-1,idx-2,idx-3];
    extrema(idx)=[];
    extr_volume=length(extrema)/4;
    x=floor((extrema(3:4:end)-1)./(n./(2.^(extrema(1:4:end)-2))))+1;
    y=mod((extrema(3:4:end)-1),m./(2.^(extrema(1:4:end)-2)))+1;
    ry=y./2.^(octave-1-extrema(1:4:end));
    rx=x./2.^(octave-1-extrema(1:4:end));
    figure(2)
    subplot(2,2,3);
    imshow(origin)
    hold on
    plot(ry,rx,'g+');
    for i=1:extr_volume
        x=floor((extrema(4*(i-1)+3)-1)/(n/(2^(extrema(4*(i-1)+1)-2))))+1;
        y=mod((extrema(4*(i-1)+3)-1),m/(2^(extrema(4*(i-1)+1)-2)))+1;
        rx=x+1;
        ry=y+1;
        rz=extrema(4*(i-1)+2);
            Dxx=D{extrema(4*(i-1)+1)}(rx-1,ry,rz)+D{extrema(4*(i-1)+1)}(rx+1,ry,rz)-2*D{extrema(4*(i-1)+1)}(rx,ry,rz);
            Dyy=D{extrema(4*(i-1)+1)}(rx,ry-1,rz)+D{extrema(4*(i-1)+1)}(rx,ry+1,rz)-2*D{extrema(4*(i-1)+1)}(rx,ry,rz);
            Dxy=D{extrema(4*(i-1)+1)}(rx-1,ry-1,rz)+D{extrema(4*(i-1)+1)}(rx+1,ry+1,rz)-D{extrema(4*(i-1)+1)}(rx-1,ry+1,rz)-D{extrema(4*(i-1)+1)}(rx+1,ry-1,rz);
            deter=Dxx*Dyy-Dxy*Dxy;
            R=(Dxx+Dyy)/deter;
            R_threshold=(r+1)^2/r;
            if(deter<0||R>R_threshold)
                extrema(4*(i-1)+4)=0;
            end

    end
    idx=find(extrema==0);
    idx=[idx,idx-1,idx-2,idx-3];
    extrema(idx)=[];
    extr_volume=length(extrema)/4;
    x=floor((extrema(3:4:end)-1)./(n./(2.^(extrema(1:4:end)-2))))+1;
    y=mod((extrema(3:4:end)-1),m./(2.^(extrema(1:4:end)-2)))+1;
    ry=y./2.^(octave-1-extrema(1:4:end));
    rx=x./2.^(octave-1-extrema(1:4:end));
    figure(2)
    subplot(2,2,4);
    imshow(origin)
    hold on
    plot(ry,rx,'b+');
    toc
end