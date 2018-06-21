
% This function stabilizes the video in the given InputVid path 
% and create a new stabilized video in the given OutputVid path

% Prepare input and output full names for the stabilization:
InputFilename = 'grafiti2.mp4';
OutputFilename = 'grafiti2.avi';

InputVideo = VideoReader(InputFilename);
OutputVideo = VideoWriter(OutputFilename); 
open(OutputVideo);

progressMessageStep = 15;


disp('Converting...');
disp(strcat('Progress message will appear every  ', num2str(progressMessageStep), ' frames.'));

frame = 0;
while hasFrame(InputVideo)
    frame = frame + 1;
    CurrentFrame = readFrame(InputVideo);
    
    writeVideo(OutputVideo, CurrentFrame);
        
    % Progress the reference frame
    %ReferenceFrameGray = CurrentFrameGray;

    % Display some vidal-signs for the user:
    if (mod(frame,progressMessageStep) == 0)
        disp(strcat('Processing frame #', num2str(frame)));
    end
end
close(OutputVideo);
disp('Finished converting.');

