% Student Name: VIN ISHIN
% Student ID: LS1706203
% ------------------------

function varargout = LS1706203_Project(varargin)
% LS1706203_PROJECT MATLAB code for LS1706203_Project.fig
%      LS1706203_PROJECT, by itself, creates a new LS1706203_PROJECT or raises the existing
%      singleton*.
%
%      H = LS1706203_PROJECT returns the handle to a new LS1706203_PROJECT or the handle to
%      the existing singleton*.
%
%      LS1706203_PROJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LS1706203_PROJECT.M with the given input arguments.
%
%      LS1706203_PROJECT('Property','Value',...) creates a new LS1706203_PROJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LS1706203_Project_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LS1706203_Project_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LS1706203_Project

% Last Modified by GUIDE v2.5 11-Jun-2018 18:56:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LS1706203_Project_OpeningFcn, ...
                   'gui_OutputFcn',  @LS1706203_Project_OutputFcn, ...
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


% --- Executes just before LS1706203_Project is made visible.
function LS1706203_Project_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LS1706203_Project (see VARARGIN)

% Choose default command line output for LS1706203_Project
handles.output = hObject;

a = ones(256, 256);
axes(handles.axes1);
imshow(a);
axes(handles.axes2);
imshow(a);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LS1706203_Project wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LS1706203_Project_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnBrowse.
function btnBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to btnBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif;*.bmp;*.jpeg'},'File Selector');
if isequal(filename, 0) || isequal(pathname, 0)
    disp('User pressed cancel');
    return;
end
handles.myImage = strcat(pathname, filename);
axes(handles.axes1);
handles.myImage = imread(handles.myImage);
imshow(handles.myImage);

h = imfreehand(gca);
xy = h.getPosition;
xCoordinates = xy(:, 1);
yCoordinates = xy(:, 2);
handles.xCoordinates = xCoordinates;
handles.yCoordinates = yCoordinates;

% Changing value at those pixels which have value as 255 to have pixel value as 254.
% This is being done to ensure that the region that is to be inpainted has
% not pixel value overlap with any of the pixels in the original region
handles.myImage(handles.myImage == 255) = 254;
uploadedImage = handles.myImage;
handles.uploadedImage = uploadedImage;

numberOfCoordinates = (length(handles.myImage(:, 1, 1)))*(length(handles.myImage(1, :, 1)));
imageCoordinate = zeros(numberOfCoordinates, 2);
var = 1;
for i = 1:length(handles.myImage(:, 1, 1))
    for j = 1:length(handles.myImage(1, :, 1))
        imageCoordinate(var, 2) = i;
        imageCoordinate(var, 1) = j;
        var = var + 1;
    end
end

inPolygonOrNot = inpolygon(imageCoordinate(:, 1), imageCoordinate(:, 2), xCoordinates, yCoordinates);
for someVar = 1: numberOfCoordinates
    if inPolygonOrNot(someVar) == 1
        handles.myImage(imageCoordinate(someVar, 2), imageCoordinate(someVar, 1), 1) = 0;
        handles.myImage(imageCoordinate(someVar, 2), imageCoordinate(someVar, 1), 2) = 255;
        handles.myImage(imageCoordinate(someVar, 2), imageCoordinate(someVar, 1), 3) = 0;
    end
end

%Let's construct the mask that we are going to use later
mask = zeros(length(handles.myImage(:, 1, 1)), length(handles.myImage(1, :, 1)));
for someVar = 1:numberOfCoordinates
    if inPolygonOrNot(someVar) == 1
        mask(imageCoordinate(someVar, 2), imageCoordinate(someVar, 1)) = 255;
    end
end
handles.mask = mask;
imshow(handles.myImage)

% save the updated handles object
guidata(hObject,handles);


% --- Executes on button press in btnProcess.
function btnProcess_Callback(hObject, eventdata, handles)
% hObject    handle to btnProcess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'uploadedImage')
    originalImage = handles.uploadedImage;
    imageFilled1 = regionfill(originalImage(:, :, 1), handles.xCoordinates, handles.yCoordinates);
    imageFilled2 = regionfill(originalImage(:, :, 2), handles.xCoordinates, handles.yCoordinates);
    imageFilled3 = regionfill(originalImage(:, :, 3), handles.xCoordinates, handles.yCoordinates);
    imageFilled(:, :, 1) = imageFilled1;
    imageFilled(:, :, 2) = imageFilled2;
    imageFilled(:, :, 3) = imageFilled3;
    mask = handles.mask;
    mask = mat2gray(mask);
    psz = 15;
    [inpaintedImage, C, D, fillMovie] = inpainting(imageFilled, mask, psz);
    inpaintedImage = uint8(inpaintedImage);
    handles.modifiedImage1 = inpaintedImage;
    axes(handles.axes2)
    imshow(handles.modifiedImage1)
    implay(fillMovie);
    
    % save the updated handles object
    guidata(hObject,handles);
else
    disp('No input');
end


% --- Executes on button press in btnReset.
function btnReset_Callback(hObject, eventdata, handles)
% hObject    handle to btnReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a = ones(256, 256);
axes(handles.axes1);
imshow(a);
axes(handles.axes2);
imshow(a);

handles = rmfield(handles, 'uploadedImage');

% save the updated handles object
guidata(hObject,handles);


% --- Executes on button press in btnExit.
function btnExit_Callback(hObject, eventdata, handles)
% hObject    handle to btnExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close
