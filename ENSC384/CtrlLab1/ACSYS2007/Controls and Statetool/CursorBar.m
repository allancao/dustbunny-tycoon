% CursorBar
%   Script prepares the axes ResponsePlotAxis for the Cursor Function.  The Cursor
%   enable button sets CursorBar as the "ButtonDownFcn" for the axes.

% Axes Handle : guiele.ResponsePlotAxis
% Line on Plot for cursor dot: guiele.CursorDot (Already exists)
% New line on plot for Cursor Bar: guiele.CursorBar (created in this script)
% Cursor Data UIPanel: guiele.cursorWindow
% Text on Cursor Data UIPanel: guiele.cursorTxt
%
% Figure Handle : guiele.CONTWIND
% Start Point : vabls.CurrentPoint
% Axes Vert Limits : vabls.axlims  ([Ymin Ymax])
% Zoom Out Button: guiele.zazoomzoomzoom
% New Axes Limits: vabls.XYLim ([Xmin Xmin Xmax Xmax Ymin Ymax Ymax Ymin])
%
% Note:  In the main GUI script, you have to initialize as follows:
    % guiele.CursorWindow = -1;
    % guiele.cursorTxt = -1;
    % guiele.dragBox = -1;
    % guiele.CursorBar = -1;
% , just to set them all to invalid handles.

set(guiele.ResponsePlotAxis,'ButtonDownFcn','');
vabls.CurrentPoint = get(guiele.ResponsePlotAxis,'CurrentPoint');

axes(guiele.ResponsePlotAxis);
hold on;
if ishandle(guiele.CursorBar)
    delete(guiele.CursorBar);
end

vabls.axlims = [get(guiele.ResponsePlotAxis,'YLim')];

guiele.CursorBar = line('Parent',guiele.ResponsePlotAxis,'XData',[vabls.CurrentPoint(1,1), vabls.CurrentPoint(1,1)],'YData',vabls.axlims);
set(guiele.CursorBar,'LineStyle',':','Color','r','Linewidth',2);
if ishandle(guiele.CursorDot), delete(guiele.CursorDot);end;
guiele.CursorDot = line('Parent',guiele.ResponsePlotAxis,'xdata',0,'ydata',0,'marker','none');

[guiele.CursorWindow guiele.cursorTxt guiele.CursorBar] = cursorFcn(guiele, cnstn, vabls.axlims, vabls.CurrentPoint);

hold off;

set(guiele.CONTWIND,'WindowButtonMotionFcn',...
    'eval(cnstn.ZoomPointerControl);[guiele.CursorWindow guiele.cursorTxt guiele.CursorBar] = cursorFcn(guiele, cnstn, vabls.axlims, get(guiele.ResponsePlotAxis,''CurrentPoint''));',...
    'WindowButtonUpFcn',...
    ['set(guiele.CONTWIND,''WindowButtonMotionFcn'',''eval(cnstn.ZoomPointerControl)'',''WindowButtonUpFcn'','''');'...
    'delete(guiele.CursorBar); set(guiele.ResponsePlotAxis,''ButtonDownFcn'',''CursorBar'');'],...
    'KeyPressFcn','cursorKeyFcn');

% Sets KeyPressFcn, WindowButtonUpFcn and WindowButtonMotionFcn
% cursorKeyFcn - Uses Keyboard input
% cursorFcn - Uses Mouse movement