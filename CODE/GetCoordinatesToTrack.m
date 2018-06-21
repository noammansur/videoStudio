function [figurePos] = GetCoordinatesToTrack(Frame)
        f = figure;
        imshow(Frame);
        title('Mark the object for tracking - using the mouse cursor');
        pos = getPosition(imrect(gca));
        
        % figurePos = [center X coordinate, center Y coordinate, half width, 
        % half height, x velocity, y velocity]
        figurePos = round([pos(1) + pos(3)/2, pos(2) + pos(4)/2, pos(3)/2, pos(4)/2, 0, 0]');
        close(f);
end

