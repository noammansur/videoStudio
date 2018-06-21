function TrackObject(inputVidName, outputVidName, numberOfParticles)
    % This code is widely based on HW3 implementation
    inputVideo = VideoReader(inputVidName);
    TrackingVid = VideoWriter(outputVidName);
    TrackingVid.FrameRate = inputVideo.FrameRate; 
    open(TrackingVid);
    
    % waitbar
    h = waitbar(0,'Tracking Progress:');
    numOfFrames = ceil(inputVideo.FrameRate*inputVideo.Duration);
    
    % LOAD FIRST IMAGE
    I = readFrame(inputVideo);
    s_initial = GetCoordinatesToTrack(I);

    % CREATE INITIAL PARTICLE MATRIX 'S' (SIZE 6xnumberOfParticles)
    S = predictParticles(repmat(s_initial, 1, numberOfParticles));

    % COMPUTE NORMALIZED HISTOGRAM
    q = compNormHist(I,s_initial);

    % COMPUTE NORMALIZED WEIGHTS (W) AND PREDICTOR CDFS (C)
    W = zeros(1, numberOfParticles);
    for n = 1:numberOfParticles
        p = compNormHist(I,S(:,n));
        W(n) = compBatDist(p,q);
    end

    W = W/sum(W);
    C = cumsum(W);
    
    frameWithBoundary = addBoundaryToFrame(I, S, W);
    writeVideo(TrackingVid, frameWithBoundary);
    
    frameCount = 0;
    while hasFrame(inputVideo)
        frameCount=frameCount+1;
        S_prev = S;
        % LOAD NEW IMAGE FRAME
        I = readFrame(inputVideo);

        % SAMPLE THE CURRENT PARTICLE FILTERS
        S_next_tag = sampleParticles(S_prev,C);

        % PREDICT THE NEXT PARTICLE FILTERS (YOU MAY ADD NOISE
        S = predictParticles(S_next_tag);

        % COMPUTE NORMALIZED WEIGHTS (W) AND PREDICTOR CDFS (C)
        W = zeros(1, numberOfParticles);
        for n = 1:numberOfParticles
            p = compNormHist(I,S(:,n));
            W(n) = compBatDist(p,q);
        end

        W = W/sum(W);
        C = cumsum(W);

        frameWithBoundary = addBoundaryToFrame(I, S, W);
        writeVideo(TrackingVid, frameWithBoundary);
        waitbar(frameCount/numOfFrames, h);
    end
    waitbar(1, h);
    close(h);
    close(TrackingVid);
end
