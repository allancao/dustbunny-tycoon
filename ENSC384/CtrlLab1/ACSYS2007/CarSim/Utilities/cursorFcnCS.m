
function [CursorWindow cursorTxt CursorBar mouseIndex] = cursorFcnCS(axHandle,handles)

mousePos = get(axHandle,'CurrentPoint');
CursorWindow = handles.CursorWindow;
cursorTxt = handles.cursorTxt;
CursorBar = handles.CursorBar;

CYAN = 0.95*[1 1 1];
LIGHTGREY = [0.9 0.9 1];

kids = get(axHandle,'Children');
kids = findobj(kids,'type','line');
kids = kids(find(kids ~= CursorBar));

set(kids,'Erasemode','none');

currTime = get(kids,'Xdata');
currTime = currTime{end};
currPosDat = get(kids,'YData');

currPos = [];

for ii = length(currPosDat)-1:-1:0
    if length(currPosDat{length(currPosDat) - ii}) > 2
        currPos = [currPos; currPosDat{length(currPosDat) - ii}];
    end
end

if length(currTime) == 0
    currTime = 0;
    currPos = 0;
end

mouseIndex = find(currTime >= mousePos(1,1),1,'first');
if isempty(mouseIndex) mouseIndex = length(currTime); end


set(CursorBar,'XData',[currTime(mouseIndex) currTime(mouseIndex)]);

cursordisplaystring = ['Time: ' num2str(currTime(mouseIndex))];
copyString = ['[' num2str(currTime(mouseIndex),'%15.15f')];
for ii = 1:min(size(currPos))
    cursordisplaystring = strvcat(cursordisplaystring, ['Line ' num2str(ii) ': ' num2str(currPos(ii,mouseIndex))]);
    copyString = [ copyString ',' num2str(currPos(ii,mouseIndex),'%15.15f')];
end
copyString = [copyString ']'];

try
    delete(findobj('Tag','CursorDot'));
end

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
                ['delete(findobj(''Tag'',''CursorDot'')); delete(get(gcbo,''Parent'')); set([findobj(''Tag'',''AxesInput'') findobj(''Tag'',''AxesOutput'')],''ButtonDownFcn'','''');'...
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