function out = hist3dhsv(image)
    %HIST3DHSV calculates a 3d histogram (3-tensor) with normalized bin
    %   counts. Bin widths are fixed at 256/32 = 8 with RGB values rounded
    %   down to the bin below. This is equivalent to the bin index being
    %   the first 5 bits of the 8-bit value for this channel (plus one
    %   since indices in Matlab begin at 1).
    %
    %   IMAGE is a standard X*Y*3 image
    
    
    
    %convert image to hsv format
    image = rgb2hsv(image);
    %reshape into a single column of pixels, i.e. (X * Y) by 3
    data = reshape(image, [], 3);
    out = double(zeros(32,32,32));
    dims = size(data);
    for i = 1:dims(1)
        %rgb2hsv scales into the 0.0-1.0 space, so multiply by 32 and add 1
        %   to get an index between 1 (0.0) and 33 (1.0)
        point = floor(double(data(i, :)) * 32) + 1;
        %if and only a coordinate was exactly 1, it is converted to 33.
        %   make sure it is 32 instead.
        point(point == 33) = 32;
        if data(i, :) ~= [0 0 0]
            out(point(1), point(2), point(3)) = out(point(1), point(2), point(3)) + 1;
        end
    end
    tot = sum(out(:));
    if (tot > 0)
        out = out / tot;
    end
end