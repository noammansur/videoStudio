function Stabilize(InputVidName,OutputVidName, resizeFactor)
    % This function stabilizes the video in the given InputVid path 
    % and create a new stabilized video in the given OutputVid path

    % Prepare input and output full names for the stabilization:
    ptThresh = 0.1;
    InputVideo = VideoReader(InputVidName);
    OutputVideo = VideoWriter(OutputVidName); 
    open(OutputVideo);

    % ReadFirstFrame
    colorImg = imresize(readFrame(InputVideo),resizeFactor);
    imgB = rgb2gray(colorImg);
    pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);
    [featuresB, pointsB] = extractFeatures(imgB, pointsB);
    writeVideo(OutputVideo,colorImg)

    % Estimate number of frames for wait bar and start wait bar
    NumberOfFrames = ceil(InputVideo.FrameRate*InputVideo.Duration);
    w = waitbar(0, 'Stabilizing...');

    frameIdx = 0;
    Hcumulative = eye(3);

    while hasFrame(InputVideo)
        frameIdx = frameIdx + 1;
        imgA = imgB;
        % Get Next Image
        colorImg = imresize(readFrame(InputVideo),resizeFactor);
        % Convert to Grayscale
        imgB = rgb2gray(colorImg);

        % Generate Prospective Points
        pointsA = pointsB;
        pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);

        % Extract Features for the Corners
        featuresA = featuresB;
        [featuresB, pointsB] = extractFeatures(imgB, pointsB);

        % Match Features
        indexPairs = matchFeatures(featuresA, featuresB);
        selectedPointsA = pointsA(indexPairs(:, 1), :);
        selectedPointsB = pointsB(indexPairs(:, 2), :);

        [tform] = estimateGeometricTransform(selectedPointsB, selectedPointsA, 'affine');

        % Extract Rotation & Translations
        H = tform.T;
        R = H(1:2,1:2);

        theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
        scale = mean(R([1 4])/cos(theta));
        translation = H(3, 1:2);

        % Reconstitute Trnasform
        HsRt = [[scale*[cos(theta) -sin(theta); sin(theta) cos(theta)]; ...
            translation], [0 0 1]'];
        Hcumulative = HsRt*Hcumulative;

        % Perform Transformation on Color Image
        img = imwarp(colorImg, affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));

        % Save Transformed Color Image to Video File
        writeVideo(OutputVideo,img);
        waitbar(frameIdx/NumberOfFrames,w); 
    end
    waitbar(1,w);  
    close(w);
    close(OutputVideo);
    disp('Finished stabilization.');
end




