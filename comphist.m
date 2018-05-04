function out = comphist(image, xsize, ysize, s, ref, ref2)
% COMPHIST Compute a fixed-window transform of an image into a competitive
% histogram score
%   IMAGE is the image to be scored
%   XSIZE is the width of the sliding window in pixels
%   YSIZE is the height of the sliding window in pixels
%   S is the resolution in window position, in pixels. Higher values
%       correspond to a lower-resolution scan and less accurate results
%   REF is a 32*32*32 hsv normalized histogram generated by hist3dhsv() on
%       the set of pixels formed from instances of the target class.
%   REF2 is the corresponding normalized histogram for pixels that are NOT
%       part of target class instances
%
%   OUT is a grayscale image of the same dimensions as IMAGE, with each
%       pixel containing a score from the comparison of REF and REF2 across
%       all passes. Positive scores mean the pixel is more likely to belong
%       to class REF, while negative scores mean the pixel is more likely
%       to belong to class REF2.
%   Note: many combinations of XSIZE, YSIZE, and S mean that pixels at the
%       bottom or very right of the image are not captured by any scan.
%       These pixels are set in OUT to a highly negative value, i.e. one
%       indicating non-membership in REF.
    dims = size(image);
    out = zeros(dims(1), dims(2));
    nums = zeros(dims(1),dims(2));
    %window starts at 1 and ends at the end minus XSIZE. step size is s
    for x1 = 1:s:(dims(1) - xsize)
        %window starts at 1 and ends at end minus YSIZE. step size is s
        for y1 = 1:s:(dims(2) - ysize)
            %calculate x and y ends of window
            x2 = x1 + xsize;
            y2 = y1 + ysize;
            %calculate 3d hsv histogram for this window
            data = hist3dhsv(double(image(x1:x2,y1:y2,:)) / 255);
            %calculate squared difference of REF from window
            scores1 = data - ref;
            scores1 = scores1 .* scores1;
            %calculate squared difference of REF2 from window
            scores2 = data - ref2;
            scores2 = scores2 .* scores2;
            %out is updated, with every pixel in the window being
                %decreased if the window deviates from REF, and increased
                %if the window deviates from REF2
            out(x1:x2,y1:y2) = out(x1:x2,y1:y2) - sum(scores1(:)) + sum(scores2(:));
            %track of how many windows contributed to each pixel's score
            nums(x1:x2,y1:y2) = nums(x1:x2,y1:y2) + 1;
        end
    end
        %normalize score using number of windows for each pixel
        out = out ./ nums;
        %no windows results in nan. Set these far below 0 threshold.
        out(isnan(out)) = -1e3;
end