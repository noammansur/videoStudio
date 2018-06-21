function varargout = runme(varargin)
% runme MATLAB code for runme.fig
%      runme, by itself, creates a new runme or raises the existing
%      singleton*.
%
%      H = runme returns the handle to a new runme or the handle to
%      the existing singleton*.
%
%      runme('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in runme.M with the given input arguments.
%
%      runme('Property','Value',...) creates a new runme or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before runme_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to runme_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help runme

% Last Modified by GUIDE v2.5 21-Jun-2018 19:55:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @runme_OpeningFcn, ...
                   'gui_OutputFcn',  @runme_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before runme is made visible.
function runme_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to runme (see VARARGIN)

% Choose default command line output for runme
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes runme wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = runme_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in inputVid.
function inputVid_Callback(~, eventdata, handles)
% hObject    handle to inputVid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    inputFileName = '../../INPUT/INPUT.avi';
    showVideo(inputFileName);
    
% --- Executes on button press in bgImg.
function bgImg_Callback(hObject, eventdata, handles)
% hObject    handle to bgImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    backgroundFileName = '../../INPUT/background.jpg';
    if(checkFileExists(backgroundFileName))
        figure;
        imshow(backgroundFileName);
    end
    
    
% --- Executes on button press in stabVid.
function stabVid_Callback(hObject, eventdata, handles)
% hObject    handle to stabVid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    stabilizedFileName = '../../OUTPUT/stabilized.avi';
    showVideo(stabilizedFileName);



% --- Executes on button press in binVid.
function binVid_Callback(hObject, eventdata, handles)
% hObject    handle to binVid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    binaryFileName = '../../OUTPUT/binary.avi';
    showVideo(binaryFileName);


% --- Executes on button press in matVid.
function matVid_Callback(hObject, eventdata, handles)
% hObject    handle to matVid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Files
    mattedFileName = '../../OUTPUT/matted.avi';
    showVideo(mattedFileName);



% --- Executes on button press in outVid.
function outVid_Callback(hObject, eventdata, handles)
% hObject    handle to outVid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    outputFileName = '../../OUTPUT/OUTPUT.avi';
    showVideo(outputFileName);


% --- Executes on button press in extVid.
function extVid_Callback(hObject, eventdata, handles)
% hObject    handle to extVid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    extractedFileName = '../../OUTPUT/extracted.avi';
    showVideo(extractedFileName);


% --- Executes on button press in stbilizeBtn.
function stbilizeBtn_Callback(hObject, eventdata, handles)
% hObject    handle to stbilizeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        inputFileName = '../../INPUT/INPUT.avi';
        if (checkFileExists(inputFileName) == 0)
            return;
        end
        resizeFactorStruct = findobj('Tag','resizeFactorText');
        resizeFactor = str2double(resizeFactorStruct.String);
        if (resizeFactor < 0 || resizeFactor > 1)
            msgbox('Resize Factor is invalid, choose between 0 to 1');
            return;
        end
        stabilizedFileName = '../../OUTPUT/stabilized.avi';
        Stabilize(inputFileName, stabilizedFileName, resizeFactor);
        msgbox('Stabilization is Done!');
     
% --- Executes on button press in BgSubBtn.
function BgSubBtn_Callback(hObject, eventdata, handles)
% hObject    handle to BgSubBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    stabilizedFileName = '../../OUTPUT/stabilized.avi';
    if (checkFileExists(stabilizedFileName) == 0)
            return;
    end
    windowDurationStruct = findobj('Tag','windowDurationText');
    windowDuration = str2double(windowDurationStruct.String);
    videoReader = VideoReader(stabilizedFileName);
    numberOfFrames = videoReader.numberOfFrames;
    if (windowDuration < 0 || windowDuration > numberOfFrames)
        msgbox(sprintf('Window duration is invalid, enter a number between 0 to %d', numberOfFrames));
        return;
    end
    bgThresholdStruct = findobj('Tag','bgThresholdText');
    bgThreshold = str2double(bgThresholdStruct.String);
    if (bgThreshold < 0 || bgThreshold > 1)
        msgbox('Background threshold is invalid, choose between 0 to 1');
        return;
    end
    binaryFileName = '../../OUTPUT/binary.avi';
    extractedFileName = '../../OUTPUT/extracted.avi';
    SubstractBackground(stabilizedFileName, binaryFileName, extractedFileName, windowDuration, bgThreshold);
    msgbox('Background substraction is Done!');
    

% --- Executes on button press in matBtn.
function matBtn_Callback(hObject, eventdata, handles)
% hObject    handle to matBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    stabilizedFileName = '../../OUTPUT/stabilized.avi';
    binaryFileName = '../../OUTPUT/binary.avi';
    backgroundFileName = '../../INPUT/background.jpg';
    if (~checkFileExists(stabilizedFileName) || ~checkFileExists(binaryFileName) || ~checkFileExists(backgroundFileName))
            return;
    end
    mattedFileName = '../../OUTPUT/matted.avi';
    Matting(stabilizedFileName, binaryFileName, backgroundFileName, mattedFileName);
    msgbox('Matting is Done!');

% --- Executes on button press in trackBtn.
function trackBtn_Callback(hObject, eventdata, handles)
% hObject    handle to trackBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    mattedFileName = '../../OUTPUT/matted.avi';
    if (~checkFileExists(mattedFileName))
                return;
    end
    numOfParticlesStruct = findobj('Tag','numberOfParticlesText');
    numOfParticles = str2double(numOfParticlesStruct.String);
    if (numOfParticles < 1 || numOfParticles > 200)
        msgbox('Number of particles is invalid, enter a number between 1 to 200');
        return;
    end
    outputFileName = '../../OUTPUT/OUTPUT.avi';
    TrackObject(mattedFileName, outputFileName, numOfParticles);
    msgbox('Tracking is Done!');

    % --- Executes on button press in runAll.
function runAll_Callback(hObject, eventdata, handles)
% hObject    handle to runAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % Check files    
    inputFileName = '../../INPUT/INPUT.avi';
    backgroundFileName = '../../INPUT/background.jpg';
    if (~checkFileExists(inputFileName) || ~checkFileExists(backgroundFileName))
        return;
    end
    % Stabilize
    resizeFactorStruct = findobj('Tag','resizeFactorText');
    resizeFactor = str2double(resizeFactorStruct.String);
    if (resizeFactor < 0 || resizeFactor > 1)
        msgbox('Resize Factor is invalid, choose between 0 to 1');
        return;
    end
    stabilizedFileName = '../../OUTPUT/stabilized.avi';
    Stabilize(inputFileName, stabilizedFileName, resizeFactor);
    
    % Background substraction
    windowDurationStruct = findobj('Tag','windowDurationText');
    windowDuration = str2double(windowDurationStruct.String);
    videoReader = VideoReader(stabilizedFileName);
    numberOfFrames = videoReader.numberOfFrames;
    if (windowDuration < 0 || windowDuration > numberOfFrames)
        msgbox(sprintf('Window duration is invalid, enter a number between 0 to %d', numberOfFrames));
        return;
    end
    bgThresholdStruct = findobj('Tag','bgThresholdText');
    bgThreshold = str2double(bgThresholdStruct.String);
    if (bgThreshold < 0 || bgThreshold > 1)
        msgbox('Background threshold is invalid, choose between 0 to 1');
        return;
    end
    binaryFileName = '../../OUTPUT/binary.avi';
    extractedFileName = '../../OUTPUT/extracted.avi';
    SubstractBackground(stabilizedFileName, binaryFileName, extractedFileName, windowDuration, bgThreshold);
    
    % Matting
    mattedFileName = '../../OUTPUT/matted.avi';
    Matting(stabilizedFileName, binaryFileName, backgroundFileName, mattedFileName);
    
    % Tracking
    numOfParticlesStruct = findobj('Tag','numberOfParticlesText');
    numOfParticles = str2double(numOfParticlesStruct.String);
    if (numOfParticles < 1 || numOfParticles > 200)
        msgbox('Number of particles is invalid, enter a number between 1 to 200');
        return;
    end
    outputFileName = '../../OUTPUT/OUTPUT.avi';
    TrackObject(mattedFileName, outputFileName, numOfParticles);
    msgbox('All Done!');


function exists = checkFileExists(fileName)
    exists=1;
    if(~exist(fileName,'file'))
            msgbox(sprintf('%s File Does Not Exist!',fileName));
            exists = 0;
    end
    
function showVideo(videoName)
    if (checkFileExists(videoName))
        implay(videoName);
    end
    
function bgThresholdText_Callback(hObject, eventdata, handles)
% hObject    handle to bgThresholdText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bgThresholdText as text
%        str2double(get(hObject,'String')) returns contents of bgThresholdText as a double


% --- Executes during object creation, after setting all properties.
function bgThresholdText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bgThresholdText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function resizeFactorText_Callback(hObject, eventdata, handles)
% hObject    handle to resizeFactorText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resizeFactorText as text
%        str2double(get(hObject,'String')) returns contents of resizeFactorText as a double


% --- Executes during object creation, after setting all properties.
function resizeFactorText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resizeFactorText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numberOfParticlesText_Callback(hObject, eventdata, handles)
% hObject    handle to numberOfParticlesText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numberOfParticlesText as text
%        str2double(get(hObject,'String')) returns contents of numberOfParticlesText as a double


% --- Executes during object creation, after setting all properties.
function numberOfParticlesText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numberOfParticlesText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function windowDurationText_Callback(hObject, eventdata, handles)
% hObject    handle to windowDurationText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of windowDurationText as text
%        str2double(get(hObject,'String')) returns contents of windowDurationText as a double


% --- Executes during object creation, after setting all properties.
function windowDurationText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windowDurationText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
