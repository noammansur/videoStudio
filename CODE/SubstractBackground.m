function SubstractBackground(InputVidName, OutputBinaryVidName, OutputExtractedVidName, WindowSize, BgFgThreshold)
% Background substration based on sliding window median in time.

% Function API:
% Inputs:
%    - InputVidName: the name of the input (stable) video.
%    - OutputExtractedVidName: the desired name of the 
%       output video, of the extracted object.
%    - OutputBinaryVidName: the desired name of the 
%       output video, of the extracted object's mask.

% Load input video and prepare output:
InputVideo = VideoReader(InputVidName);
Height = InputVideo.Height;
Width = InputVideo.Width;
OutputVideo = VideoWriter(OutputExtractedVidName);
OutputBinaryVideo = VideoWriter(OutputBinaryVidName);
OutputVideo.FrameRate = InputVideo.FrameRate; 
open(OutputVideo);
OutputBinaryVideo.FrameRate = InputVideo.FrameRate; 
open(OutputBinaryVideo);

% Get number of frames
NumberOfFrames = InputVideo.numberOfFrames;
InputVideo = VideoReader(InputVidName);

w = waitbar(0, 'Subtracting Background...');
FrameIdx = 1;
disp('Reading input file...');
InputInGray = zeros(NumberOfFrames,Height,Width);
InputInR = zeros(NumberOfFrames,Height,Width);
InputInG = zeros(NumberOfFrames,Height,Width);
InputInB = zeros(NumberOfFrames,Height,Width);
while hasFrame(InputVideo)
    FrameToRead = readFrame(InputVideo);
    temp = rgb2hsv(FrameToRead);
    InputInGray(FrameIdx,:,:) = im2double(temp(:,:,3));
    InputInR(FrameIdx,:,:) = FrameToRead(:,:,1);
    InputInG(FrameIdx,:,:) = FrameToRead(:,:,2);
    InputInB(FrameIdx,:,:) = FrameToRead(:,:,3);
    FrameIdx = FrameIdx + 1;
    waitbar(FrameIdx/(NumberOfFrames * 2),w);  
end
waitbar(0.5,w);

NumberOfFrames = FrameIdx-1;
disp(strcat('Finished reading input video, #Frames= ',num2str(NumberOfFrames)));

% calculate median over time on a window of the size of the given WindowSize
% on edges, calculate on smaller window
BackgroundPerFrame = movmedian(InputInGray, WindowSize);

%movBack2 = movmedian(InputInGray, ceil(WindowSize/2),'Endpoints','fill');

disp(strcat('Finished calculating background'));

edges = round(WindowSize/3.5);
% Main loop for BG substraction:
for FrameIdx = 1:NumberOfFrames
    if (FrameIdx < edges) || (FrameIdx > NumberOfFrames-(2*edges))
        level = 0.04;
    else
        level = BgFgThreshold;
    end
    currentFrame = double(InputInGray(FrameIdx,:,:));
    currentBackground = double(BackgroundPerFrame(FrameIdx,:,:));
    % Gaussian filter used to smooth binary output:
    filter = fspecial('gaussian',30);
    currentFrame = imfilter(currentFrame,filter);
    currentBackground = imfilter(currentBackground,filter);
    
    diffFrame = abs(currentFrame - currentBackground);
    diffFrame = squeeze(diffFrame);
    ForegroundMask = im2double(diffFrame > level );
    
    ForegroundMask = isolatePerson(ForegroundMask,Width,Height);
    
    % Create "binary.avi" output:
    ForegroundMaskToWrite = double(~ForegroundMask);
    writeVideo(OutputBinaryVideo, im2uint8(ForegroundMaskToWrite));
    
    % Create "extracted.avi" output:    
    ForegroundR = uint8(ForegroundMask).*uint8(squeeze(InputInR(FrameIdx,:,:)));
    %turn black pixels to white
    BlackPixels = find(ForegroundMask == 0);
    ForegroundR(BlackPixels) = 255; 
    ForegroundG = uint8(ForegroundMask).*uint8(squeeze(InputInG(FrameIdx,:,:)));
    %turn black pixels to white
    ForegroundG(BlackPixels) = 255;
    ForegroundB = uint8(ForegroundMask).*uint8(squeeze(InputInB(FrameIdx,:,:)));
    %turn black pixels to white
    ForegroundB(BlackPixels) = 255;
    
    ForegroundRGB = cat(3,ForegroundR,ForegroundG,ForegroundB); 
    writeVideo(OutputVideo,ForegroundRGB);
           
    waitbar(0.5 + FrameIdx/(NumberOfFrames * 2),w);  
    
end
close(w);
close(OutputVideo);
close(OutputBinaryVideo);

disp('Finished substracting background.');
end
