% An alert box pops up with the string args displayed using latex
% interpreter.

% figg - figure handle
% position - [l b w h] in pixels

% Returns a handle to the window (UIPanel)
% Uses hoverBox.m

% You could turn this into a script.  Just delete the "function Popup..."
% line and correct the handle names in the code.

function PopupWindow = alertBoxCS(figg,position,showtext,titlebar);

CYAN = 0.9*[1 1 1];
LIGHTGREY = [0.8 0.8 1];

margin = 20;
buffer = 5;
    % The popup window - could change the position
    PopupWindow = uipanel('Parent',figg,'Units','pixels','Position',position,...
        'BackGroundColor',CYAN,'BorderType','beveledout','ButtonDownFcn','','Visible','on');
    % Top bar - lets you drag.  Don't need to touch.
    CursorWindowBar = uicontrol('Parent',PopupWindow,'Style','text','Units','pixels','Enable','off',...
                'Position',[1 position(4)-margin position(3)-2 margin-1],'BackGroundColor',LIGHTGREY,'String',titlebar,...
                'ButtonDownFcn',['hoverBoxCS(' num2str(figg,'%15.15f') ',' num2str(PopupWindow,'%15.15f') ',gcbo);']);
    
    % Container so that the popup box isn't transparent over axes.
    TextContainer = uicontrol('Parent',PopupWindow,'Style','text','Units','pixels','Enable','off',...
                'Position',[1 1 position(3)-2 position(4)-margin-1],'BackGroundColor',CYAN,'String','');
    
    textbox = uicontrol('Parent',PopupWindow,'Style','text','Units','pixels','Enable','on',...
                'Position',[buffer buffer position(3)-buffer*2 position(4)-margin-buffer*2],...
                'BackGroundColor',CYAN,'String','','HorizontalAlignment','left',...
                'ButtonDownFcn','');
    
    % showtext = strvcat(textwrap(textbox,showtext));
    showtext = textwrap(textbox,showtext);
    set(textbox,'String',showtext);
    
    % Close Button...  Could add things to callback, but don't need to
    % change anything else
    uicontrol('Parent',PopupWindow,'Units','pixels','Style','PushButton','String','X',...
                'Position',[position(3)-margin+1 position(4)-margin+1 margin-2 margin-2],'Callback',...
                ['delete('  num2str(PopupWindow,'%15.15f') ');']);     
