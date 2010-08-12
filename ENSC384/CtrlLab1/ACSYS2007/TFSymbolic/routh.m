function varargout = routh(varargin)
    % ROUTH M-file for routh.fig
    %      ROUTH, by itself, creates a new ROUTH or raises the existing
    %      singleton*.
    %
    %      H = ROUTH returns the handle to a new ROUTH or the handle to
    %      the existing singleton*.
    %
    %      ROUTH('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in ROUTH.M with the given input arguments.
    %
    %      ROUTH('Property','Value',...) creates a new ROUTH or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before routh_OpeningFunction gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to routh_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help routh

    % Last Modified by GUIDE v2.5 28-May-2007 16:46:26

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @routh_OpeningFcn, ...
                       'gui_OutputFcn',  @routh_OutputFcn, ...
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


% --- Executes just before routh is made visible.
function routh_OpeningFcn(hObject, eventdata, handles, varargin)

    handles.num = get(handles.num_edit,'String');
    handles.den = get(handles.den_edit,'String');

    % Choose default command line output for routh
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes routh wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = routh_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;



function num_edit_Callback(hObject, eventdata, handles)
    handles.num = get(hObject,'String');
    guidata(hObject, handles);
    % --- Executes during object creation, after setting all properties.

function num_edit_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function den_edit_Callback(hObject, eventdata, handles)
    handles.den = char(get(hObject,'String'));
    guidata(hObject, handles);;

function den_edit_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end




% --- Executes on button press in rhst_button.
function rhst_button_Callback(hObject, eventdata, handles)
    syms eps;
    S = parsePoly(handles.den);
    ra = simple(routheval(S,eps))
    pretty(ra)

