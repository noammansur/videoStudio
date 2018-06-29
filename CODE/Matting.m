function Matting(InputVid, InputBinary, Background, OutputVid)
% Creating I/O objects & Initializing parameters:
InputReader = VideoReader(InputVid);
InputBinaryReader = VideoReader(InputBinary);
numOfFrames = ceil(InputReader.FrameRate*InputReader.Duration);
Width = InputReader.Width;
Height = InputReader.Height;
outputVideo = VideoWriter(OutputVid);
outputVideo.FrameRate = InputReader.FrameRate; 
open(outputVideo);

% Resizing background due to the video size:
BackgroundImage = imread(Background);
BackgroundImage = imresize(BackgroundImage, [Height Width]);
BackgroundImage = double(BackgroundImage)/255;

% Waitbar:
h = waitbar(0,'Matting Progress:');

% Matting initialization:
FGIndicesNum = 0; BGIndicesNum=0; Frame = 0;
while FGIndicesNum == 0 || BGIndicesNum==0
    Frame = Frame + 1;
    RefFrame = readFrame(InputReader);
    RefBinary = readFrame(InputBinaryReader);
    RefBinaryV = im2bw(RefBinary);
    
    % Sampling foreground and background for histogram calculation:
    [FGXIndices, FGYIndices] = find(RefBinaryV == 1); 
    [BGXIndices, BGYIndices] = find(RefBinaryV == 0);
    [FGIndicesNum,~] = size(FGXIndices); 
    [BGIndicesNum,~] = size(BGXIndices);
end
NumOfSamples = min(floor(FGIndicesNum/50),floor(BGIndicesNum/50));
SamplesFG = randsample(1:FGIndicesNum,NumOfSamples); 
SamplesBG = randsample(1:BGIndicesNum,NumOfSamples);
FG_Sampled_X_Indices = FGXIndices(SamplesFG); 
FG_Sampled_Y_Indices = FGYIndices(SamplesFG); 
BG_Sampled_X_Indices = BGXIndices(SamplesBG); 
BG_Sampled_Y_Indices = BGYIndices(SamplesBG);

% Histogram calculation for foreground and background:
PixelValues = 0:255;
RefFrameHSV = rgb2hsv(RefFrame);
RefVFrame = RefFrameHSV(:,:,3)*255;
FGscribbleColors = RefVFrame(FG_Sampled_X_Indices,FG_Sampled_Y_Indices);
[FG_Dens,~]=ksdensity(FGscribbleColors(:),PixelValues);
BGscribbleColors = RefVFrame(BG_Sampled_X_Indices, BG_Sampled_Y_Indices);
[BG_Dens,~]=ksdensity(BGscribbleColors(:),PixelValues);

% Iterating over the numOfFrames and matting the object and background
while hasFrame(InputReader)
    Frame = Frame + 1;
    % Getting a new frame:
    CurrFrameRGB = double(readFrame(InputReader))/255;
    CurrFrameHSV = rgb2hsv(CurrFrameRGB);
    CurrVFrame   = CurrFrameHSV(:,:,3);
    CurrBinaryFrame = im2bw(readFrame(InputBinaryReader));
	
	% Finding perimeter and widenning the object (narrow band):
	NB = imdilate(bwperim(CurrBinaryFrame), strel('disk', 1, 0));
	NB_VALUES = double(CurrVFrame).*double(NB);

	% Calculating likelihood:
    NB_Indices = find(NB_VALUES == 0);
	FG_P = FG_Dens(NB_VALUES*255+1);
    BG_P = BG_Dens(NB_VALUES*255+1);
	BG_Pf = double(BG_P./(FG_P+BG_P));
	FG_Pf = double(FG_P./(FG_P+BG_P));
    BG_Pf(NB_Indices) = 0;
    FG_Pf(NB_Indices) = 0;
    
    % Calculating alpha map:
    AlphaMap = FG_Pf./(FG_Pf+BG_Pf);
    AlphaMap(isnan(AlphaMap)) = 1-CurrBinaryFrame(isnan(AlphaMap));
    
    % Building the combined frame:
    BG = cat(3,(1-AlphaMap).*BackgroundImage(:,:,1),(1-AlphaMap).*BackgroundImage(:,:,2),(1-AlphaMap).*BackgroundImage(:,:,3)); 
    FG = cat(3,AlphaMap.*CurrFrameRGB(:,:,1),AlphaMap.*CurrFrameRGB(:,:,2),AlphaMap.*CurrFrameRGB(:,:,3));  
    MattedFrame = BG + FG;
    writeVideo(outputVideo, MattedFrame);
    waitbar(Frame/numOfFrames, h);
end

waitbar(1, h);
close(outputVideo);
close(h);
end
