% cursorKeyFcnCS
%   The KeyPressFcn for the axes object when the cursor function is turned
%   on.     Left and Right arrows - Small Jump = 1 point
%           Up and Down Arrows - Big Jump = 100 points

function [CursorWindow cursorTxt mouseIndex] = cursorKeyFcnCS(axHandle,handles)


mousePos = get(axHandle,'CurrentPoint');
CursorWindow = handles.CursorWindow;
cursorTxt = handles.cursorTxt;
mouseIndex = handles.CursorIndex;

CYAN = 0.95*[1 1 1];
LIGHTGREY = [0.9 0.9 1];
try
    delete(findobj('Tag','CursorDot'));
end
kids = findobj(get(axHandle,'Children'),'type','line');

set(kids,'Erasemode','none');

currTime = get(kids,'Xdata');
currTime = currTime{end};
currPosDat = get(kids,'YData');

currPos = [];

for ii = length(currPosDat)-1:-1:0
    if length(currPosDat{length(currPosDat) - ii}) > 3
        currPos = [currPos; currPosDat{length(currPosDat) - ii}];
    end
end

if length(currTime) == 0
    currTime = 0;
    currPos = 0;
end

currChar = double(get(handles.CarSim,'CurrentCharacter'));

%         case 28 % left arrow
%         case 29 % right arrow
%         case 30 % up arrow
%         case 31 % down arrow
if ~isempty(currChar)
    switch currChar
        case 28
            mouseIndex = mouseIndex - 1;
        case 29
            mouseIndex = mouseIndex + 1;
        case 30 
            mouseIndex = mouseIndex + 100;
        case 31
            mouseIndex = mouseIndex - 100;
    end
end

if mouseIndex < 1
    mouseIndex = 1;
end
if mouseIndex > length(currTime)
    mouseIndex = length(currTime);
end

CYAN = 0.95*[1 1 1];
LIGHTGREY = [0.9 0.9 1];

set(axHandle,'NextPlot','add');



CursorDot = line('Parent',axHandle,'XData',currTime(mouseIndex)*ones(1,min(size(currPos))),'YData',(currPos(:,mouseIndex))',...
    'Marker','s','LineStyle','none','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',4,'EraseMode','xor',...
    'tag','CursorDot');

cursordisplaystring = ['Time: ' num2str(currTime(mouseIndex))];
copyString = ['[' num2str(currTime(mouseIndex),'%15.15f')];
for ii = 1:min(size(currPos))
    cursordisplaystring = strvcat(cursordisplaystring, ['Line ' num2str(ii) ': ' num2str(currPos(ii,mouseIndex))]);
    copyString = [ copyString ',' num2str(currPos(ii,mouseIndex),'%15.15f')];
end
copyString = [copyString ']'];


if ~ishandle(CursorWindow)
    CursorWindow = uipanel(handles.CarSim,'Units','pixels','Position',...
        [handles.cnst.cpwidth+handles.cnst.displaywidth-250 handles.cnst.displayheight/2-100 handles.cnst.bwidth 4*handles.cnst.bheight+20],...
        'BackGroundColor',LIGHTGREY,'BorderType','beveledout','ButtonDownFcn','','Visible','on');
    cursorTxt = uicontrol('Parent',CursorWindow,'Style','text','Units','Normalized','FontSize',6,...
                'Position',[0 0 1 0.83],'BackGroundColor',CYAN,...
                'String',cursordisplaystring,'UserData',copyString,...
                'fontsize',10,'FontWeight','Demi','BackgroundColor',CYAN);
    CursorWindowBar = uicontrol('Parent',CursorWindow,'Style','text','Units','Normalized','Enable','off',...
                'Position',[0 0.85 1 0.15],'BackGroundColor',LIGHTGREY,'String','Cursor Values',...
                'ButtonDownFcn','hoverBoxCS(gcf,get(gcbo,''Parent''),gcbo);');
    uicontrol('Parent',CursorWindow,'Units','Normalized','Style','PushButton','String','X',...
                'Position',[0.9 0.85 0.09 0.15],'Callback',...
                ['delete(get(gcbo,''Parent'')); set([findobj(''Tag'',''AxesInput'') findobj(''Tag'',''AxesOutput'')],''ButtonDownFcn'','''');'...
                'set(gcf,''Pointer'',''arrow'',''WindowButtonMotionFcn'','''',''WindowButtonUpFcn'','''',''KeyPressFcn'','''');']);
    uicontrol('Parent',CursorWindow,'Units','pixels','Style','Pushbutton','String','Copy Point',...
                'Position',[20 2 handles.cnst.bwidth-40 20],...
                'UserData',cursorTxt,...
                'Callback',['clipboard(''copy'',get(get(gcbo,''UserData''),''UserData''));']);
else
    set(cursorTxt,'String',cursordisplaystring,'UserData',copyString);
end

% Unnecessary Feature:
idx = [find(handles.SimData(1,:) > handles.SimData(1,mouseIndex)-3.1,1,'first'):find(handles.SimData(1,:) < handles.SimData(1,mouseIndex)+3.1,1,'last')];
SpringDamper(handles.SpringDamper,handles.SimData(2,mouseIndex),handles.SimData(3,mouseIndex),[(handles.SimData(1,idx)-handles.SimData(1,mouseIndex));handles.SimData(2,idx)],handles.ExperimentSelect);