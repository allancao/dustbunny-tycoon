% cursorBar
%   Script prepares the axes hAX(1) for the Cursor Function.  The Cursor
%   enable button sets cursorBar as the "ButtonDownFcn" for the axes.
%
% guiel.cursorPB=uicontrol(guiel.cPanel(4),'Style','PushButton','Units','pixels',...
% 	'Position',[2*cnst.icwidth 0 cnst.icwidth cnst.icwidth],'Enable','on','CData',iccursor,'TooltipString',guiel.cursorTt,...
%     'CallBack',['if ishandle(guiel.CursorWindow) delete(guiel.CursorWindow);'...
%                 'set(guiel.hAX(1),''ButtonDownFcn'','''');'...
%                 'set(guiel.oTrace(3),''XData'',0,''YData'',0,''Marker'',''none''); end;'...
%                 'set(guiel.hAX(1),''ButtonDownFcn'',''cursorBar''); set(guiel.zoomzoom,''Enable'',''on'');']); 
%  
% Axes Handle : guiel.hAX(1)
% Line on Plot for cursor dot: guiel.oTrace(3) (Already exists)
% New line on plot for Cursor Bar: guiel.CursorBar (created in this script)
% Cursor Data UIPanel: guiel.cursorWindow
% Text on Cursor Data UIPanel: guiel.cursorTxt
%
% Figure Handle : guiel.APPWINDOW
% Start Point : vars.CurrentPoint
% Axes Vert Limits : vars.axlims  ([Ymin Ymax])
% Zoom Out Button: guiel.zazoomzoomzoom
% New Axes Limits: vars.XYLim ([Xmin Xmin Xmax Xmax Ymin Ymax Ymax Ymin])
%
% Note:  In the main GUI script, you have to initialize as follows:
    % guiel.CursorWindow = -1;
    % guiel.cursorTxt = -1;
    % guiel.dragBox = -1;
    % guiel.CursorBar = -1;
% , just to set them all to invalid handles.

set(guiel.hAX(1),'ButtonDownFcn','');
vars.CurrentPoint = get(guiel.hAX(1),'CurrentPoint');

axes(guiel.hAX(1));
hold on;
if ishandle(guiel.CursorBar)
    delete(guiel.CursorBar);
end

vars.axlims = [get(guiel.hAX(1),'XLim') get(guiel.hAX(1),'YLim')];

guiel.CursorBar = line('Parent',guiel.hAX(1),'XData',[vars.CurrentPoint(1,1), vars.CurrentPoint(1,1)],'YData',vars.axlims(3:4));
set(guiel.CursorBar,'LineStyle',':','Color','r','Linewidth',2);

[guiel.CursorWindow guiel.cursorTxt guiel.CursorBar] = cursorFcn(guiel, cnst, input, vars.response_type, vars.axlims(3:4), vars.CurrentPoint);

hold off;

set(guiel.APPWINDOW,'WindowButtonMotionFcn',...
    'eval(codeblk.ZoomPointerControl); [guiel.CursorWindow guiel.cursorTxt guiel.CursorBar] = cursorFcn(guiel, cnst, input, vars.response_type, vars.axlims(3:4), vars.CurrentPoint);',...
    'WindowButtonUpFcn',...
    ['set(guiel.APPWINDOW,''WindowButtonMotionFcn'',''eval(codeblk.ZoomPointerControl);'',''WindowButtonUpFcn'','''');'...
    'delete(guiel.CursorBar); set(guiel.hAX(1),''ButtonDownFcn'',''cursorBar'');'],...
    'KeyPressFcn','[guiel.CursorWindow guiel.cursorTxt] = cursorKeyFcn(guiel, cnst, input, vars.response_type);');

% Sets KeyPressFcn, WindowButtonUpFcn and WindowButtonMotionFcn
% cursorKeyFcn - Uses Keyboard input
% cursorFcn - Uses Mouse movement