% cursorKeyFcn
%   The KeyPressFcn for the axes object when the cursor function is turned
%   on.     Left and Right arrows - Small Jump = 1 point
%           Up and Down Arrows - Big Jump = 100 points
%


% guiele.oTrace(1) - handle the the line data
% guiele.oTrace(3) - handle to the cursor point line
% guiele.CursorWindow - the Cursor Window UIPanel
% guiele.cursorTxt - the text in the Cursor Window


%function [CursorWindow cursorTxt] = cursorKeyFcn(guiele, cnstn, input, response_type)
CursorWindow = guiele.CursorWindow;
cursorTxt = guiele.cursorTxt;

currTime = get(guiele.ResponsePlotLine,'XData');
currPos = get(guiele.ResponsePlotLine,'YData');
mouseIndex = find(currTime >= get(guiele.CursorDot,'XData'),1,'first');

if isempty(mouseIndex) mouseIndex = length(currTime); end

currChar = double(get(guiele.CONTWIND,'CurrentCharacter'));

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
            mouseIndex = mouseIndex + 10;
        case 31
            mouseIndex = mouseIndex - 10;
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

% hold on
% plot(guiele.hAX(1),output.time(mouseIndex),output.values(mouseIndex),'rs','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',4);
set(guiele.CursorDot,'XData',currTime(mouseIndex),'YData',currPos(mouseIndex),'Marker','s',...
    'MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',4);
if ~ishandle(guiele.CursorWindow)
    CursorWindow = uipanel(guiele.CONTWIND,'Units','pixels','Position',[cnstn.cpwidth-cnstn.bhspace cnstn.bvspace cnstn.bwidth 2*cnstn.bheight],...
        'BackGroundColor',CYAN,'BorderType','beveledout','ButtonDownFcn','selectmoveresize','Visible','on');
    cursorTxt = uicontrol('Parent',CursorWindow,'Style','text','Units','Normalized','FontSize',6,...
                'Position',[0 0 1 1],...
                'String',strvcat(['Time: ' num2str(currTime(mouseIndex))],[response_type ': ' num2str(currPos(mouseIndex))],['Input: ' num2str(input.signals.values(mouseIndex))]),...
                'fontsize',10,'FontWeight','Demi','BackgroundColor',CYAN);
    CursorWindowBar = uicontrol('Parent',CursorWindow,'Style','text','Units','Normalized','Enable','off',...
                'Position',[0 0.8 1 0.2],'BackGroundColor',LIGHTGREY,'String','Cursor Values',...
                'ButtonDownFcn','HoverBox');
    uicontrol('Parent',CursorWindow,'Units','Normalized','Style','PushButton','String','X',...
                'Position',[0.9 0.8 0.09 0.2],'Callback',...
                'delete(guiele.CursorWindow);set(guiele.oTrace(3),''XData'',[0],''YData'',[0],''Marker'',''none'');set(guiele.hAX(1),''ButtonDownFcn'','''');');

else
    set(cursorTxt,'String',strvcat(['Time: ' num2str(currTime(mouseIndex))],['Output: ' num2str(currPos(mouseIndex))]));
end