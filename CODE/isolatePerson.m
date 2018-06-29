function [OutForegroundMask] = isolatePerson(InForegroundMask,Width,Height)
% this function assumes the person is the larget object on the frame
% and returnes a binary frame with the person alone, with as little noise
% as possible
% Inspired by:
% https://www.mathworks.com/matlabcentral/answers/112917-how-to-detect-hand
    sigma = 24;
    % Apply Median filter to remove Noise
    % The filter is vertical like the person
    InForegroundMask=medfilt2(InForegroundMask,[30 1]);
    labeledImage = bwlabel(InForegroundMask);
    measurements = regionprops(labeledImage, 'Area');
    allAreas = [measurements.Area];
    % Sort areas in descending order.
    [area, sortedIndices] = max(allAreas);
    % The person is the largest object in each frame.
    if (size(sortedIndices) > 0)
        objectLabel = sortedIndices(1);  
        object = ismember(labeledImage, objectLabel);
        % Findind the object's start and end x coordinates.
        [Y, X] = find(object == 1);
        xMinOfObject = min(X);
        xMaxOfObject = max(X);
        yMinOfObject = min(Y);
        yMaxOfObject = max(Y);
        % Remove from frame all elements that are not above or below the object.
        InForegroundMask(:,1:xMinOfObject) = 0;
        InForegroundMask(:,xMaxOfObject:Width) = 0;
        InForegroundMask(1:yMinOfObject,:) = 0;
        InForegroundMask(yMaxOfObject:Height,:) = 0;
    end
    % the obejct is not in the frame - the larget object is noise
    if (~isempty(area))
        if (area < 800)
            InForegroundMask(:,:) = 0;
        else
            %Apply Median filter to remove Noise
            InForegroundMask=medfilt2(InForegroundMask,[16 10]);
            % remove connected objects smaller than given argument
            InForegroundMask = bwareaopen(InForegroundMask, ceil(area/2));
        end
    end
    OutForegroundMask = InForegroundMask;
end

