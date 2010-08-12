% simlab
% simlab  -	A MATLAB based application used to examine various aspects
% of motor control, with the following experiments:
%   1. Closed Loop Speed Control
%   2. Position Control
%   3. Open Loop Speed Control
%   4. Frequency Reponse
%   5. Simulated Control Design Project
% To run the application, just type "virtuallab" 
% at the matlab prompt while working in the "Virtual Lab" folder.
% After this point all operations are done with custom GUI controls.
%
% © Farid Golnaraghi 1993, 1999, 2002, 2007
% The MechWorks Software Inc., Waterloo, Ont., Canada
% Version 2007 - First Trial
%=============================================================
% Author: Johannes Minor
% SIMLab
% Last Modified: July 3, 2007
%=============================================================

% TEMPLATE FOR ACSYS FIGURE, CONTROL PANEL AND DISPLAY PANEL
guiel = struct;         % GUI Element Handles
cnst = struct;          % Display Property and Experiment Constants
vars = struct;          % Experiment variables
codeblk = struct;       % Code Blocks

cnst.cpheight = 600;    % Control Panel Height
cnst.cpwidth = 275;     % Control Panel Width
cnst.dpmargins = 1;     % Margins around the Display Panel
cnst.displaywidth = 1;  % Current Width of Display Panel
cnst.displayheight = 1;
cnst.mindpwidth = 600;    % Minimum Display Panel Width
cnst.hmargin = 5;       % Panel Margin - Horizontal
cnst.vmargin = 17;      % Panel Margin - Vertical

cnst.bwidth = 180;      % Button Width
cnst.bheight = 24;      % Button Height
cnst.bvspace = 15;      % Vertical  and Horizontal Space Between Buttons
cnst.bhspace = (cnst.cpwidth-2*cnst.hmargin-cnst.bwidth)/2;
cnst.icwidth = 30;      % Icon Button Width and Height

cnst.panel1BHeight = 3*cnst.bvspace + cnst.bheight;
cnst.panel2BHeight = 4*cnst.bvspace + 2*cnst.bheight;
cnst.panel3BHeight = 5*cnst.bvspace + 3*cnst.bheight;
cnst.panel4BHeight = 6*cnst.bvspace + 4*cnst.bheight;
cnst.panelWidth = cnst.cpwidth-2*cnst.hmargin;

cnst.MARGIN = 0.02;
cnst.OFFWHITE = [1 1 0.9];   % Predefined Colors
cnst.LIGHTGREY = [0.9 0.9 0.9];
cnst.CYAN = [0.95 0.95 0.95];

codeblk = struct;

% Figure Title
vars.title_string = 'SIMLab © 2002-2008 Farid Golnaraghi';

%Adds all the folders for Virtual Lab to the Path Menu
cnst.p = cd;
addpath(genpath(cnst.p))


%===================================================================
% CREATE FIGURE AND BASE PANELS
%===================================================================

guiel.APPWINDOW = 113;
if ishandle(guiel.APPWINDOW)
    delete(guiel.APPWINDOW);
end

figure(guiel.APPWINDOW);
set(guiel.APPWINDOW,'Units','Normalized','Position',[0.1 0.1 0.8 0.8],...
	'Name',vars.title_string,'ResizeFcn','','Toolbar','none','DockControls','off',...
	'color',cnst.LIGHTGREY,'NumberTitle','off','Menubar','None');

guiel.ControlPanel = uipanel('Parent',guiel.APPWINDOW,'BorderType','none','CreateFcn','',...
    'BackgroundColor',cnst.LIGHTGREY,'Units','pixels','Position',[0 0 1 1],'Title','');

guiel.DisplayPanel = uipanel('Parent',guiel.APPWINDOW,'BorderType','etchedin','CreateFcn','',...
    'BackgroundColor',cnst.OFFWHITE,'Units','pixels','Position',[275 0 1 1],'Title','');

guiel.FillerPanel = uipanel('Parent',guiel.APPWINDOW,'BorderType','none','CreateFcn','',...
    'BackgroundColor',cnst.LIGHTGREY,'Units','pixels','Position',[0 0 1 1],'Title','');



codeblk.placePanels = ['old_units = get(guiel.APPWINDOW,''Units'');'...
                'set(guiel.APPWINDOW,''Units'',''pixels'');'...
                'figpos = get(guiel.APPWINDOW,''Position'');'...
                'if figpos(3) < (cnst.mindpwidth + cnst.cpwidth) figpos(3) = (cnst.mindpwidth + cnst.cpwidth);set(guiel.APPWINDOW,''Position'',figpos);end,'...
                'if figpos(4) < (cnst.cpheight) figpos(2) = (figpos(2)+figpos(4)-cnst.cpheight); figpos(4) = cnst.cpheight;set(guiel.APPWINDOW,''Position'',figpos); end,'...
                'cnst.displaywidth = figpos(3)-cnst.cpwidth-2*cnst.dpmargins;'...
                'cnst.displayheight = figpos(4) - 2*cnst.dpmargins;'...
                'set(guiel.ControlPanel,''Position'',[0, figpos(4) - cnst.cpheight, cnst.cpwidth, cnst.cpheight]);'...
                'set(guiel.DisplayPanel,''Position'',[cnst.cpwidth+cnst.dpmargins 0+cnst.dpmargins cnst.displaywidth figpos(4)-2*cnst.dpmargins]);'...
                'set(guiel.FillerPanel,''Position'',[0 0 cnst.cpwidth figpos(4) - cnst.cpheight+1]);'...
                'set(guiel.APPWINDOW,''Position'',figpos);'...
                'set(guiel.APPWINDOW,''Units'',old_units); clear old_units figpos;'];
            
eval(codeblk.placePanels);

codeblk.CLEAN_UP = ['eval(codeblk.stopTimer); eval(codeblk.cleanButtonFcns);'...
            'if ~all(isempty(guiel.cPanel)) delete(guiel.cPanel(:)); end;'...
            'if ishandle(guiel.hAX(1)) set(guiel.hAX(1),''ButtonDownFcn'',''''); delete(guiel.hAX(1)); end;'...
            'if ishandle(guiel.hAX(2)) delete(guiel.hAX(2)); end;'...
            'if ishandle(guiel.hAX(3)) delete(guiel.hAX(3)); end;'...
            'if ishandle(guiel.tfPanel) delete(guiel.tfPanel); end;'...
            'if ishandle(guiel.CursorWindow) delete(guiel.CursorWindow); end,'...
            'set(guiel.APPWINDOW,''Resize'',''on'');'];

%===================================================================
% UIMENUS
%===================================================================
guiel.h_MN(01)= uimenu('Parent',guiel.APPWINDOW,'Label','Experiment');
    uimenu('Parent',guiel.h_MN(01),'Label','1: Speed Control','Callback','eval(codeblk.CLEAN_UP); exp1_sim','Accelerator','1');
    uimenu('Parent',guiel.h_MN(01),'Label','2: Position Control','Callback','eval(codeblk.CLEAN_UP); exp2_sim','Accelerator','2');
    uimenu('Parent',guiel.h_MN(01),'Label','3: Open Loop Speed','Callback','eval(codeblk.CLEAN_UP); exp3_sim','Accelerator','3');
    uimenu('Parent',guiel.h_MN(01),'Label','4: Open Loop Sine Input','Callback','eval(codeblk.CLEAN_UP); exp4_sim','Accelerator','4');
    uimenu('Parent',guiel.h_MN(01),'Label','5: Control System Design','Callback','eval(codeblk.CLEAN_UP); exp5_sim','Accelerator','5');
    uimenu('Parent',guiel.h_MN(01),'Label','Quit','Callback','del_globalvars; eval(codeblk.SHUT_DOWN)',... 
            'Separator','on','Accelerator','Q');
guiel.h_MN(02)=uimenu('Parent',guiel.APPWINDOW,'Label','&Calculator','CallBack','!calc.exe;');
guiel.h_MN(03)=uimenu('Parent',guiel.APPWINDOW,'Label','&Unit Conversion','CallBack','conver');
guiel.h_MN(04)=uimenu('Parent',guiel.APPWINDOW,'Label','Help Me','CallBack','');

set(guiel.APPWINDOW,'CloseRequestFcn','try if ~isempty(timerfindall) stop(timerfindall); delete(timerfindall); end; del_globalvars; rmpath(genpath(cnst.p)); clear cnst guiel vars voltage codeblk hght rd anim tout input output velocity magnet; closereq;  catch, set(gcbo,''CloseRequestFcn'',''closereq''); clear all; close(gcbo); end,',...
        'ResizeFcn','eval(codeblk.placePanels);');

codeblk.placePanels = [codeblk.placePanels 'set(guiel.cPanel(4),''Position'',[3*cnst.displaywidth/4-3*cnst.icwidth/2 cnst.bvspace 3*cnst.icwidth cnst.icwidth]);'...
                        'set(guiel.TFSelectBox,''Position'',[2 cnst.displayheight-cnst.bheight-2 cnst.bwidth cnst.bheight]);'];

guiel.TFSelectBox = -1;
% Prepare for Experiment 1.
exp1_sim;