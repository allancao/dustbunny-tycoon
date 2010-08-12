% hoverBox
% Used as the ButtonDownFcn of guiel.CursorWindow top bar.
% 
% vars.startPoint : location of intial click on Figure in pixels ([X,Y])
% vars.startPos : the location of the CursorWindow in the figure
% vars.currpos : the current position of the CursorWindow during drag
% figure handle: guiel.APPWINDOW

function hoverBox(figg,hPanel,topbar);

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
    'vars.newPoint = get(' figadd ',''CurrentPoint'') - startPoint;'...
    'vars.currpos(1:2) = startPos(1:2) + vars.newPoint;'...
    'vars.currpos(3:4) = startPos(3:4);'...
    'if (vars.currpos(1)+vars.currpos(3) > figlims(3)) vars.currpos(1) = figlims(3)-vars.currpos(3); end;'...
    'if (vars.currpos(2)+vars.currpos(4) > figlims(4)) vars.currpos(2) = figlims(4)-vars.currpos(4); end;'...
    'set(' hPaneladd ',''Position'',vars.currpos,''Units'',''Pixels'');'],...
    'WindowButtonUpFcn',...
    ['global startPoint startPos MotionFcn UpFcn DownFcn figlims; set(' figadd ',''WindowButtonMotionFcn'',MotionFcn,''WindowButtonUpFcn'',UpFcn);'...
    'set(' figadd ',''Units'',''Normalized'',''pointer'',''arrow'');'...
    'set(' num2str(topbar,'%15.15f') ',''ButtonDownFcn'',DownFcn);clear global MotionFcn UpFcn startPoint startPos figlims DownFcn;']);

end
