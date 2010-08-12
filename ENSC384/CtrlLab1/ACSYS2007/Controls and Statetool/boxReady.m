% boxReady
%   Prepares the axes guiele.ResponsePlotAxis for the zoom select box.  The Zoom In
%   button sets boxReady as the "ButtonDownFcn" of the axes.
%
%   Ex:
% guiel.zoomzoom=uicontrol(guiel.cPanel(4),'Style','PushButton','Units','pixels',...
% 	'Position',[0 0 cnstn.icwidth cnstn.icwidth],'Enable','on',...
%     'CData',iczoomin,'TooltipString',guiel.zoominTt,'CallBack',...
%     'set(guiel.ResponsePlotAxis,''ButtonDownFcn'',''boxReady'');set(guiel.zoomzoom,''Enable'',''off'');');
%
% Axes Handle : guiel.ResponsePlotAxis
% Patch Handle : guiel.dragBox
% Figure Handle : guiel.APPWINDOW
% Start Point : vabls.CurrentPoint
% Axes Limits : vabls.axlims  ([Xmin Xmax Ymin Ymax])
% Zoom Out Button: guiel.zazoomzoomzoom
% New Axes Limits: vabls.XYLim ([Xmin Xmin Xmax Xmax Ymin Ymax Ymax Ymin])
%

vabls.CurrentPoint = get(guiele.ResponsePlotAxis,'CurrentPoint');     %This is the point the cursor is at when the user presses down. "drawBox is called again when the button is realeased and the current point then is the other corner of the patch

set(guiele.ResponsePlotLine,'erasemode','none');

XYLims=[get(guiele.ResponsePlotAxis,'xlim') get(guiele.ResponsePlotAxis,'ylim')];

axes(guiele.ResponsePlotAxis);
hold on;
if ishandle(guiele.dragBox)
    delete(guiele.dragBox);
end
guiele.dragBox = patch(guiele.ResponsePlotAxis,repmat(vabls.CurrentPoint(1,1),[1 4]),repmat(vabls.CurrentPoint(1,2),[1 4]));
set(guiele.dragBox,'FaceColor','none','EdgeColor','r','LineStyle',':');

hold off;

set(guiele.zazoomzoomzoom,'Enable','on');

vabls.axlims = [get(guiele.ResponsePlotAxis,'XLim') get(guiele.ResponsePlotAxis,'YLim')];


set(guiele.CONTWIND,'Units','pixels','WindowButtonMotionFcn',...
    'eval(cnstn.ZoomPointerControl); vabls.XYLims = drawBox(guiele.dragBox,vabls.CurrentPoint,vabls.axlims,get(guiele.ResponsePlotAxis,''CurrentPoint''));',...
    'WindowButtonUpFcn',...
    ['set(guiele.CONTWIND,''WindowButtonMotionFcn'',''eval(cnstn.ZoomPointerControl);'',''WindowButtonUpFcn'','''');'...'
    'vabls.XYLim = [get(guiele.dragBox,''Xdata'') get(guiele.dragBox,''YData'')];,'...
    'set(guiele.CONTWIND,''Units'',''Normalized''); delete(guiele.dragBox);'...
    'if numel(vabls.XYLim) >=4 && ~any(any(isnan(vabls.XYLim)))'...
        'diffLim = diff(vabls.XYLim); diffAx = diff(vabls.axlims);'...
        'if diffLim(2,1) > diffAx(1)/100 && diffLim(1,2) > diffAx(3)/100 '...
            'set(guiele.ResponsePlotAxis,''XLim'',[vabls.XYLim(1,1) vabls.XYLim(3,1)],''YLim'',[vabls.XYLim(1,2) vabls.XYLim(3,2)]);'...
        'eval(cnstn.ZoomHousekeeping);',...
        'end,'...
        'clear diffLim diffAx;'...
     'end,'...
     'vabls.axlims = [get(guiele.ResponsePlotAxis,''XLim'') get(guiele.ResponsePlotAxis,''YLim'')];'...
     'set(guiele.ResponsePlotLine,''erasemode'',''normal'');',... 
     ]);

 