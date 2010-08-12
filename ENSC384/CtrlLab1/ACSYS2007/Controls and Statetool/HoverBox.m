% HoverBox
% Used as the ButtonDownFcn of guiel.CursorWindow top bar.
% 
% vabls.startPoint : location of intial click on Figure in pixels ([X,Y])
% vabls.startPos : the location of the CursorWindow in the figure
% vabls.currpos : the current position of the CursorWindow during drag
% figure handle: guiele.APPWINDOW

function HoverBox(figg,hPanel,topbar);

try
global startPoint
global startPos
global MotionFcn
global UpFcn
global DownFcn
global figlims

DownFcn = get(topbar,'ButtonDownFcn');
set(topbar,'ButtonDownFcn','');
set(figg,'Units','pixels','pointer','fleur');
figlims = get(figg,'Position');

figadd = num2str(figg,'%15.15f');
hPaneladd = num2str(hPanel,'%15.15f');
startPoint = get(figg,'CurrentPoint');
startPos = get(hPanel,'Position');
MotionFcn = get(figg,'WindowButtonMotionFcn');
UpFcn = get(figg,'WindowButtonUpFcn');


set(figg,'WindowButtonMotionFcn',...
    ['global startPoint startPos MotionFcn UpFcn DownFcn figlims;'...
    'vabls.newPoint = get(' figadd ',''CurrentPoint'') - startPoint;'...
    'vabls.currpos(1:2) = startPos(1:2) + vabls.newPoint;'...
    'vabls.currpos(3:4) = startPos(3:4);'...
    'if (vabls.currpos(1)+vabls.currpos(3) > figlims(3)) vabls.currpos(1) = figlims(3)-vabls.currpos(3); end;'...
    'if (vabls.currpos(2)+vabls.currpos(4) > figlims(4)) vabls.currpos(2) = figlims(4)-vabls.currpos(4); end;'...
    'set(' hPaneladd ',''Position'',vabls.currpos,''Units'',''Pixels'');'],...
    'WindowButtonUpFcn',...
    ['global startPoint startPos MotionFcn UpFcn DownFcn figlims; set(' figadd ',''WindowButtonMotionFcn'',MotionFcn,''WindowButtonUpFcn'',UpFcn);'...
    'set(' figadd ',''Units'',''Normalized'',''pointer'',''arrow'');'...
    'set(' num2str(topbar,'%15.15f') ',''ButtonDownFcn'',DownFcn); eval(UpFcn); clear global MotionFcn UpFcn startPoint startPos figlims DownFcn;']);

end