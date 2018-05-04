function out = hist3d(image)
    data = reshape(image, [], 3);
    out = double(zeros(32,32,32));
    dims = size(data);
    for i = 1:dims(1)
        point = floor(double(data(i, :)) / 8) + 1;
        if data(i, :) ~= [0 0 0]
            out(point(1), point(2), point(3)) = out(point(1), point(2), point(3)) + 1;
        end
    end
    tot = sum(out(:));
    if (tot > 0)
        out = out / tot;
    end
end