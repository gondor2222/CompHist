points = [];
points2 = [];
%ignore non-integer index warnings, we are using non-integer indices to
    %subsample images with float coordinates (which are automatically
    %rounded)
warning('off', 'MATLAB:colon:nonIntegerIndex');
for i=1:20
    imname = strcat('s',int2str(i)); %name of strawberry image variable
    maskname = strcat('bw', int2str(i)); %name of mask image variable
    %load strawberry image and mask image for this index into variables
    eval([imname ' = imread(strcat(''train/'',imname,''.JPG''));']);
    eval([maskname ' = imread(strcat(''train/s'',int2str(i),''mask.png''));']);
    dims = [ 0 0 0];
    %get size of image
    eval([strcat('dims = size(',imname,');')]);
    %calculate sample rate in pixels; a 500 pixel image has every pixel sampled,
    %1000 means every 2, etc
    scale = dims(1) / 500;
    
    %downsample images so that image is exactly 500 pixels high
    eval([strcat(imname, ' = ',imname,'(1:scale:end,1:scale:end,:);')]);
    eval([strcat(maskname, ' = ',maskname,'(1:scale:end,1:scale:end);')]);
    eval(['dims = size(' imname ');']);
    %due to rounding errors, images may be 498 or 499 pixels tall. add
        %black to the top of the image if this happens to make image 500
        %pixels tall
    if (dims(1) < 500)
        str = strcat(imname, ' = [zeros(', int2str(500 - dims(1)), ',', int2str(dims(2)), ',3) ; ', imname, '];');
        eval([str]);
        str2 = strcat(maskname, ' = [zeros(', int2str(500 - dims(1)), ',', int2str(dims(2)), ') ; ', maskname, '];');
        eval([str2]);
    end
    %extract target pixels from image using mask
    outname = strcat('masked', int2str(i));
    eval([outname ' = uint8(' maskname '(:,:,[1 1 1])) .*' imname ';']);
    %extract non-target pixels from image using inversion of mask
    outname2 = strcat('notmasked', int2str(i));
    eval([outname2 ' = uint8(1 - ' maskname '(:,:,[1 1 1])) .*' imname ';']);
    %add target pixels to 'points' array
    eval(['points = [points ; reshape(' outname ',[],3)];']);
    %add non-target pixels to 'points2' array
    eval(['points2 = [points2 ; reshape(' outname2 ',[],3)];']);
end
warning('on', 'MATLAB:colon:nonIntegerIndex');
%remove all perfect black pixels from the points; this is the color of
    %points outside of the mask
points = points(any(points ~=0,2),:);
points2 = points2(any(points2 ~=0,2),:);
%transform into arithmetic RGB scale (0.0 - 1.0) and convert target and
    %non-target pixels into target 3d histogram and non-target 3d histogram
hist1 = hist3dhsv(double(points)/255);
hist2 = hist3dhsv(double(points2)/255);