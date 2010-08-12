% cursorBarCS
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

function cursorBarCS(axHandle, handles)

set(axHandle,'ButtonDownFcn','','NextPlot','add');
CurrentPoint = get(axHandle,'CurrentPoint');

if ishandle(handles.CursorBar)
    delete(handles.CursorBar);
end
      
handles.CursorBar = line('Parent',axHandle,'XData',[CurrentPoint(1,1), CurrentPoint(1,1)],'YData',get(axHandle,'YLim'));
set(handles.CursorBar,'LineStyle',':','Color','r','Linewidth',2,'Tag','CursorBar');

[handles.CursorWindow handles.cursorTxt handles.CursorBar handles.CursorIndex] = cursorFcnCS(axHandle, handles);

guidata(axHandle,handles);

hold off;


set(gcf,'WindowButtonMotionFcn',...
    ['eval(''CarSim(''''ZoomPointerControlBlk'''',gcbo);''); '...
    'h = guidata(gcf);'...
    '[h.CursorWindow h.cursorTxt h.CursorBar h.CursorIndex] = cursorFcnCS(gca,h);'...
    'guidata(gcf,h);'],...
    'WindowButtonUpFcn',...
    ['set(gcbo,''WindowButtonMotionFcn'',''CarSim(''''ZoomPointerControlBlk'''',gcbo);'',''WindowButtonUpFcn'','''');'...
    'delete(findobj(''Tag'',''CursorBar'')); set([findobj(''Tag'',''AxesInput'') findobj(''Tag'',''AxesOutput'')],''ButtonDownFcn'',''cursorBarCS(gcbo, guidata(gcbo));''); clear tmp;'],...
    'KeyPressFcn','hh = guidata(gcf); [hh.CursorWindow hh.cursorTxt hh.CursorIndex] = cursorKeyFcnCS(gca,hh); guidata(gcf,hh);');



% Sets KeyPressFcn, WindowButtonUpFcn and WindowButtonMotionFcn
% cursorKeyFcn - Uses Keyboard input
% cursorFcn - Uses Mouse movement