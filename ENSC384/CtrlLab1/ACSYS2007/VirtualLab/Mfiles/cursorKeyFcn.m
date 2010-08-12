% cursorKeyFcn
%   The KeyPressFcn for the axes object when the cursor function is turned
%   on.     Left and Right arrows - Small Jump = 1 point
%           Up and Down Arrows - Big Jump = 100 points
%


% guiel.oTrace(1) - handle the the line data
% guiel.oTrace(3) - handle to the cursor point line
% guiel.CursorWindow - the Cursor Window UIPanel
% guiel.cursorTxt - the text in the Cursor Window


function [CursorWindow cursorTxt] = cursorKeyFcn(guiel, cnst, input, response_type)
CursorWindow = guiel.CursorWindow;
cursorTxt = guiel.cursorTxt;

currTime = get(guiel.oTrace(1),'XData');
currPos = get(guiel.oTrace(1),'YData');
mouseIndex = find(currTime >= get(guiel.oTrace(3),'XData'),1,'first');

if isempty(mouseIndex) mouseIndex = length(currTime); end

currChar = double(get(guiel.APPWINDOW,'CurrentCharacter'));

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

% hold on
% plot(guiel.hAX(1),output.time(mouseIndex),output.values(mouseIndex),'rs','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',4);
set(guiel.oTrace(3),'XData',currTime(mouseIndex),'YData',currPos(mouseIndex),'Marker','s',...
    'MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',4,'EraseMode','xor');
if ~ishandle(guiel.CursorWindow)
    CursorWindow = uipanel(guiel.APPWINDOW,'Units','pixels','Position',[cnst.cpwidth+cnst.displaywidth-250 cnst.displayheight/2-100 cnst.bwidth 3*cnst.bheight],...
        'BackGroundColor',LIGHTGREY,'BorderType','beveledout','ButtonDownFcn','','Visible','on');
    cursorTxt = uicontrol('Parent',CursorWindow,'Style','text','Units','Normalized','FontSize',6,...
                'Position',[0 0 1 0.8],'BackGroundColor',CYAN,...
                'String',strvcat(['Time: ' num2str(currTime(mouseIndex))],[response_type ': ' num2str(currPos(mouseIndex))],['Input: ' num2str(input.signals.values(mouseIndex))]),...
                'fontsize',10,'FontWeight','Demi','BackgroundColor',CYAN);
    CursorWindowBar = uicontrol('Parent',CursorWindow,'Style','text','Units','Normalized','Enable','off',...
                'Position',[0 0.8 1 0.2],'BackGroundColor',LIGHTGREY,'String','Cursor Values',...
                'ButtonDownFcn','hoverBox(guiel.APPWINDOW,guiel.CursorWindow,gcbo);');
    uicontrol('Parent',CursorWindow,'Units','Normalized','Style','PushButton','String','X',...
                'Position',[0.9 0.8 0.09 0.2],'Callback',...
                'delete(guiel.CursorWindow);set(guiel.oTrace(3),''XData'',[0],''YData'',[0],''Marker'',''none'');set(guiel.hAX(1),''ButtonDownFcn'',''''); eval(codeblk.cleanButtonFcns);');

else
    set(cursorTxt,'String',strvcat(['Time: ' num2str(currTime(mouseIndex))],[response_type ': ' num2str(currPos(mouseIndex))],['Input: ' num2str(input.signals.values(mouseIndex))]));
end

drawnow