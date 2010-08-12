function onFileOpen
% opens a select file dialog, load a file, and resets
global femSolved;
global hMainWindow;     
global hFigure;
global hGoButton;
global hMessageBardisplace;
global hMessageBarelement;
global LastDir; % first time set to a default value (by mba), every time a file is opened it is updated

femSolved=false;
% opens a select-file dialog and attempts to load the file
% note also that the directory in which the file is opened is kept for the
% next time
[fileName, LastDir]=uigetfile('*.mat','DefaultName',LastDir);
% if "cancel" was pressed
if(fileName==0)
    LastDir='';
    return;
end;
% clear axes
set(hMainWindow,'CurrentAxes',hFigure);
cla;
% disable "analyze" buttons.
% "analyze" is enabled once a file is opened, 
set(hGoButton,'Enable','off');
% load model
if(~loadFile([LastDir fileName]))
    % if failed 
    set(hMessageBar,'String','Failed openning model');
    set(hMainWindow,'Name',['Truss_Beam FEA']); % set window title
    MsgBox('Failed opening file! please check the model file!','Error','error','modal');
    return;
end;
% direct plot output to figure axes, and draw the model
set(hMainWindow,'CurrentAxes',hFigure);
% update window title to include file name
set(hMainWindow,'Name',['Truss-Beam FEA - ' fileName]);
% enable the analyze button
set(hGoButton,'Enable','on');
set(hMessageBardisplace,'String','Model loaded Correctly');
set(hMessageBarelement,'String','Model loaded Correctly');
% show the Model
showModel;

