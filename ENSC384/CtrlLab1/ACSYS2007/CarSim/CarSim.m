function varargout = CarSim(varargin)

    % CarSim - First called from the PostLoadFcn of CarSimModel
    %   Sets up the gui if you pass it one argument which is the handle to
    %   the Simulink Model

if nargin == 1 
    % Opening Progress Meter
    progmeter(0.01,'open');
    
    % Constants for GUI Layout
    cnst = struct;
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
    
    progmeter(0.05);
    
    fig = figure('Units','Normalized',...
                'Position',[0.1 0.1 0.8 0.8],...
                'Name','Quarter Car Modelling Tool © 2007 Farid Golnaraghi',...
                'Tag','CarSim',...
                'ResizeFcn','',...
                'Interruptible','on',...
                'BusyAction','cancel',...
                'Color',[0.9 0.9 0.9],...
                'NumberTitle','off',...
                'CloseRequestFcn', 'CarSim(''CloseFcn'', gcbo, [], guidata(gcbo), [])',...
                'BackingStore', 'off',...
                'DockControls','off',...
                'Menubar','None',...
                'Visible','off');
    
    % Handles structure used for all code
    handles = guihandles(fig);

    progmeter(0.1);

    handles.fig = fig;
    % Update the path to include subdirectories
    handles.pwd = pwd;
    addpath(genpath(handles.pwd));
    
    
    % --------------------------------------------------------------
    % TEMPLATE FOR ACSYS FIGURE, CONTROL PANEL AND DISPLAY PANEL
    % --------------------------------------------------------------
    
  % Control Panel - Fixed Size  
    handles.ControlPanel = uipanel('Parent', fig,'BorderType','none','CreateFcn','',...
        'BackgroundColor',cnst.LIGHTGREY,'Units','pixels','Position',[0 0 1 1],'Title','');
  % Display Panel / Workspace - Variable Size
    handles.DisplayPanel = uipanel('Parent', fig,'BorderType','etchedin','CreateFcn','',...
        'BackgroundColor',cnst.OFFWHITE,'Units','pixels','Position',[cnst.cpwidth 0 1 1],'Title','');
  % Filler Panel - Variable Size
    handles.FillerPanel = uipanel('Parent', fig,'BorderType','none','CreateFcn','',...
        'BackgroundColor',cnst.LIGHTGREY,'Units','pixels','Position',[0 0 1 1],'Title','');

    progmeter(0.15);
    
    % Lay out the display area, limit resize
    codeblk.placePanels = ['old_units = get(fig,''Units'');'...
                'set(fig,''Units'',''pixels'');'...
                'figpos = get(fig,''Position'');'...
                'if figpos(3) < (cnst.mindpwidth + cnst.cpwidth) figpos(3) = (cnst.mindpwidth + cnst.cpwidth);set(fig,''Position'',figpos);end,'...
                'if figpos(4) < (cnst.cpheight) figpos(2) = (figpos(2)+figpos(4)-cnst.cpheight); figpos(4) = cnst.cpheight;set(fig,''Position'',figpos); end,'...
                'cnst.displaywidth = figpos(3)-cnst.cpwidth-2*cnst.dpmargins;'...
                'cnst.displayheight = figpos(4) - 2*cnst.dpmargins;'...
                'set(handles.ControlPanel,''Position'',[0, figpos(4) - cnst.cpheight, cnst.cpwidth, cnst.cpheight]);'...
                'set(handles.DisplayPanel,''Position'',[cnst.cpwidth+cnst.dpmargins 0+cnst.dpmargins cnst.displaywidth figpos(4)-2*cnst.dpmargins]);'...
                'set(handles.FillerPanel,''Position'',[0 0 cnst.cpwidth figpos(4) - cnst.cpheight+1]);'...
                'set(fig,''Position'',figpos);'...
                'set(fig,''Units'',old_units); clear old_units figpos;'];

    eval(codeblk.placePanels);
    
    
    % --------------------------------------------------------------
    [CarSimPath,name,ext,versn] = fileparts(mfilename('fullpath'));

    progmeter(0.2);
    

    progmeter(0.25);
    
    % Store handles to simulink blocks and some simulation parameters
    handles.CarSim = fig;
    handles.CarSimPath = CarSimPath;
    handles.SimModelName = varargin{1}; % Name of the calling simulink model
    handles.DistBlock = [handles.SimModelName, '/Y'''''];
    handles.CarSimBlock = [handles.SimModelName, '/To CarSim GUI'];
    handles.OutputConditioner = [handles.SimModelName, '/To CarSim GUI/Output Conditioner'];
    
    progmeter(0.27);

    handles.TFAxes = [];
    handles.ControllerParameters = -1;
    handles.ControllerParametersWindow = -1;
    handles.ModelParametersWindow = -1;
    
    progmeter(0.3);
    
    handles.PIDController = [handles.SimModelName, '/Compensator/PID Controller'];
    handles.CompensatorTF = [handles.SimModelName, '/Compensator/Compensator TF'];
    handles.FeedbackIndex = [handles.SimModelName, '/Feedback Selector/Feedback Index'];
    
    progmeter(0.31);
    % Calls subfunction to lay out buttons
    InitializeGui(fig, CarSimPath,handles,cnst);
    % Refresh handles structure
    handles = guidata(fig);
    handles.SimData = [];               % Initialize Simulation Data Array
    handles.SimDataOrder = {'t','y','z', 'x', 'y''','z''','x''','y"','z"','x"'}; 
                                        % Order of rows in the SimData
                                        % Array, after the SimData array is
                                        % created when the simulation
                                        % finishes
    handles.SimulationIsRunning = 0;    % Simulation in progress flag
    handles.SimulationTime = 3;         % Simulation Stop time.  Start time = 0.
    handles.axlims = [0 1 -1 1; 0 1 -1 1];  % Matrix of axes limits.  Updated every time new data is plotted
    
    handles.PlotSelection1 = 2;         % Variables used to store the row index of data
    handles.PlotSelection2 = 3;         % plotted on either time axis
    handles.ExternalFigure = -1;
    
    % Create some custom Pointers for the zoom and cursor Functions
        handles.MagnifyingGlass = [NaN NaN NaN NaN   1   1   1   1 NaN NaN NaN NaN NaN NaN NaN NaN;...
                        NaN NaN   1   1 NaN NaN NaN NaN   1   1 NaN NaN NaN NaN NaN NaN;...
                        NaN   1 NaN NaN NaN NaN NaN NaN NaN NaN   1 NaN NaN NaN NaN NaN;...
                        NaN   1 NaN NaN NaN NaN NaN NaN NaN NaN   1 NaN NaN NaN NaN NaN;...
                          1 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   1 NaN NaN NaN NaN;...
                          1 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   1 NaN NaN NaN NaN;...
                          1 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   1 NaN NaN NaN NaN;...
                          1 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   1 NaN NaN NaN NaN;...
                        NaN   1 NaN NaN NaN NaN NaN NaN NaN NaN   1 NaN NaN NaN NaN NaN;...
                        NaN   1 NaN NaN NaN NaN NaN NaN NaN NaN   1 NaN NaN NaN NaN NaN;...
                        NaN NaN   1   1 NaN NaN NaN NaN   1   1   1   1 NaN NaN NaN NaN;...
                        NaN NaN NaN NaN   1   1   1   1 NaN NaN   1   1   1 NaN NaN NaN;...
                        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   1   1   1 NaN NaN;...
                        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   1   1   1 NaN;...
                        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   1   1   1;...
                        NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN   1 NaN];
                    
        handles.dataCursor = [  NaN NaN  1  NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN;...
                         NaN NaN  1  NaN NaN NaN 1    1   1  NaN NaN NaN NaN NaN NaN NaN;...
                         1    1   1   1   1  NaN 1    2   1    1 NaN NaN NaN NaN NaN NaN;...
                         NaN NaN  1  NaN NaN NaN NaN NaN  1   2   1   1  NaN NaN NaN NaN;...
                         NaN NaN  1  NaN NaN NaN NaN NaN  1   2   2   1   1  NaN NaN NaN;...
                         NaN NaN NaN NaN NaN NaN NaN NaN  1   2   2   1   1   1  NaN NaN;...
                         NaN NaN NaN  1  NaN NaN NaN  1   1   2   1   1   2   1   1  NaN;...
                         NaN NaN  1   2   1  NaN NaN  1   1   2   2   1   2   1   2   1 ;...
                         NaN NaN  1   2   2    1  1   1   2   2   2   2   2   1   2   1 ;...
                         NaN NaN NaN  1   2   2   2   2   2   2   2   2   2   2   2   1 ;...
                         NaN NaN NaN  1   2   2   2   2   2   2   2   2   2   2   2   1 ;...
                         NaN NaN NaN NaN  1   2   2   2   2   2   2   2   2   2   2   1 ;...
                         NaN NaN NaN NaN NaN  1   2   2   2   2   2   2   2   2   1  NaN;...  
                         NaN NaN NaN NaN NaN NaN  1   1   2   2   2   2   2   1  NaN NaN;...
                         NaN NaN NaN NaN NaN NaN NaN  1   2   2   2   2   2   1  NaN NaN;...
                         NaN NaN NaN NaN NaN NaN NaN NaN   1  1   1   1   1  NaN NaN NaN];

    
    % Used in Animation
    handles.AnimationNextHit = 0; % Sets the hit time of the next animation frame for the Simulink animating fnc
    handles.Ground = NaN; % Stores the handles of the ground line in the animation axes
    handles.AnimationLength = 1;
    handles.DefaultAnimationScale = 1;
    handles.PTFHandle = [];
    handles.TFPopup = [];
    handles.ylim = [];
    
    % Initialize some handles for Cursor Functions
    handles.CursorWindow = -1;
    handles.cursorTxt = -1;
    handles.CursorBar = -1;
    handles.CursorIndex = -1;

    progmeter(0.38);
    

    progmeter(0.4);
    % Initialize animation
    handles.SpringDamper = SpringDamper([0,0], handles.AnimationLength, .5, .5,handles.AnimationAxes,handles.ExperimentSelect);
    handles = InitializeMenu(handles); % Create menus and add to handles structure

    progmeter(0.55);
    
    handles.cnst = cnst;
    guidata(fig, handles);
    progmeter(0.6);
    set(fig,'ResizeFcn','CarSim(''ResizeWindowFcn'', gcbo, [], guidata(gcbo), [])');
    
    ShowTF(fig, [], handles, [])
    
    progmeter(0.65);
    progmeter(0.7);
    
	if nargout > 0
		varargout{1} = fig;
    end

    progmeter(0.8);
    
    progmeter(0.9);
    
    set(fig,'Visible','on');

    progmeter(0.95,'close');
    figure(fig);
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK, IF MORE THAN 1 INPUT ARG
	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end
end


%--------------------------------------------------------------------------
%------End of CarSIM------------------------------------------------
%--------------------------------------------------------------------------

% -------------------------------------------------------------------------
function ResizeWindowFcn(fig, eventdata, handles, varargin)
    % NOTE h is the figure handle in the window resize function
    set(fig, 'units', 'pixels')
    figpos = get(fig, 'position');
    
    cnst = handles.cnst;
    

    % Check Resize Limits
    if figpos(3) < (cnst.mindpwidth + cnst.cpwidth)
        figpos(3) = (cnst.mindpwidth + cnst.cpwidth);
        set(fig,'Position',figpos);
    end
    if figpos(4) < (cnst.cpheight) 
        figpos(2) = (figpos(2)+figpos(4)-cnst.cpheight); 
        figpos(4) = cnst.cpheight;set(fig,'Position',figpos); 
    end
    
    % Adjust main layout panels
    cnst.displaywidth = figpos(3)-cnst.cpwidth-2*cnst.dpmargins;
    cnst.displayheight = figpos(4) - 2*cnst.dpmargins;
    set(handles.ControlPanel,'Position',[0, figpos(4) - cnst.cpheight, cnst.cpwidth, cnst.cpheight]);
    set(handles.DisplayPanel,'Position',[cnst.cpwidth+cnst.dpmargins 0+cnst.dpmargins cnst.displaywidth figpos(4)-2*cnst.dpmargins]);
    set(handles.FillerPanel,'Position',[0 0 cnst.cpwidth figpos(4) - cnst.cpheight+1]);
    set(fig,'Position',figpos);
    
    
    % Axes PopupMenus
    set(handles.AxesOutput,'Units','pixels');
    set(handles.AxesInput,'Units','pixels');
    pos = [0 0 0 0; 0 0 0 0];
    pos(1,:) = get(handles.AxesInput,'Position');
    pos(2,:) = get(handles.AxesOutput,'Position');
    set(handles.AxesOutput,'Units','normalized');
    set(handles.AxesInput,'Units','normalized');
    pos(1,:) = [pos(1,1)+pos(1,3)-100 pos(1,2)+pos(1,4)+2 100 20];
    pos(2,:) = [pos(2,1)+pos(2,3)-100 pos(2,2)+pos(2,4)+2 100 20];

    set(handles.ax1control,'Position',pos(1,:));
    set(handles.ax2control,'Position',pos(2,:));    
    
    if ishandle(handles.PlotSelectBox1)
        PlotSelectBox('1',fig,handles.ax1control);
    end
    if ishandle(handles.PlotSelectBox2)
        PlotSelectBox('2',fig,handles.ax2control);
    end
    
    set(fig, 'units', 'normalized')

% -------------------------------------------------------------------------
%   Initialize GUI - Called during startup from function CarSim
function InitializeGui(fig, CarSimPath,handles, cnst)

    % Load button and frame data
    GUIData = load(fullfile(CarSimPath, 'Data', 'ACSYSGUIData.mat'));

    % Organizing Control Panels
    % Model Control
    handles.cPanel(1) = uipanel('Parent', handles.ControlPanel,...
                                'BorderType','etchedin',...
                                'BackgroundColor',cnst.LIGHTGREY,...
                                'Units','pixels',...
                                'Position',...
    	[cnst.hmargin cnst.cpheight-cnst.panel3BHeight-cnst.vmargin cnst.panelWidth cnst.panel3BHeight],...
                                'Title','Model Control');
    % Simulation Control
    h2 = cnst.cpheight-cnst.panel3BHeight-cnst.panel4BHeight-2*cnst.vmargin;
    handles.cPanel(2) = uipanel('Parent',handles.ControlPanel,...
                                 'Units','pixels',...
                                 'BorderType','etchedin',...
                                 'BackgroundColor',cnst.LIGHTGREY,...
                                 'Title','Simulation','Position',...
        [cnst.hmargin h2 cnst.panelWidth cnst.panel4BHeight]);

    handles.cPanel(3) = -1;

    ACSYSButton = buildButtons(cnst,handles.cPanel(1),handles.cPanel(2),handles.ControlPanel);

    % Create main controls, configuration stored in the structured 
    % array 'GUIData.ACSYSButton' stored in 'ACSYSGUIData.mat'
    n = length(ACSYSButton);
    for i = 1:n
        
        handles.(ACSYSButton(i).Tag) = uicontrol('Style', ACSYSButton(i).Style,...
                      'Parent', ACSYSButton(i).Parent,...
                      'Units', 'pixels',...
                      'Position', ACSYSButton(i).Position,...
                      'String', ACSYSButton(i).String,...
                      'Tag', ACSYSButton(i).Tag,...
                      'Fontweight', 'demi',...
                      'Fontsize', 10,...
                      'Callback',ACSYSButton(i).Callback,...
                      'Backgroundcolor', ACSYSButton(i).Color);
    end
        handles.MeterBox = uipanel('title','',...
                        'Tag','MeterBox',...
                        'Units','pixels',...
                        'Position',[cnst.bhspace 2*cnst.bvspace+cnst.bheight cnst.bwidth cnst.bheight],...   			
                        'BackGroundColor',[1 1 1],...
                        'Parent',handles.cPanel(2),...
                        'BorderType','etchedin');

        handles.ProgressMeter = uicontrol('String','',...
                    'Style','text',...
                    'Enable','off',...
                    'Tag','ProgressMeter',...
                    'Units','Normalized',...
                    'Position',[0.01 0.01 0.2 0.98],...   			
                        'BackGroundColor',[0 0 1],...
                        'Parent',handles.MeterBox);
    
        set(handles.ProgressMeter,'Parent',handles.MeterBox,'Units','Normalized','Position',[0 0 0.01 1]);
    
        % Create ZOOM Control and DATA CURSOR Control Buttons
        handles.cPanel(4) = uipanel('Parent',handles.DisplayPanel,'Units','pixels','BorderType','none',...
                'BackgroundColor',[1 1 0.9],'Title','','Visible','off',...
                'Position',[3*cnst.displaywidth/4-90/2 cnst.bvspace 90 30]);

            handles.CursorWindow = -1;
            handles.cursorTxt = -1;
            handles.dragBox = -1;
            handles.CursorBar = -1;
            handles.drawBox = -1;
            handles.axlims = -1;

            iczoomin = imread('zoomin.jpg');
            iczoomout = imread('zoomout.jpg');
            iccursor = imread('cursor.jpg');

        % Tool Tip Strings for Zoom and Cursor Control Buttons
        cursorTt = 'Data Cursor: Click Mouse Cursor on Graph or use Arrow Keys';
        zoomoutTt = 'Zoom Out';
        zoominTt = 'Zoom In: Select Zoom Area';
     
        
            % Zoom In - Sets ButtonDownFcn for axes to boxReady, and
            % figure's WindowButtonMotionFcn to ZoomPointerControlBlk
            handles.ZoomIn=uicontrol('Parent',handles.cPanel(4),'Style','PushButton','Units','pixels',...
                'Position',[0 0 30 30],'Enable','on',...
                'CData',iczoomin,'TooltipString',zoominTt,'CallBack',...
                ['tmp = struct; tmp.fig = findobj(''Tag'',''CarSim''); tmp.handles = guidata(tmp.fig);'...
                    'set(tmp.fig,''PointerShapeCData'',tmp.handles.MagnifyingGlass);'...
                    'set(tmp.fig,''WindowButtonMotionFcn'',''CarSim(''''ZoomPointerControlBlk'''',gcbo);'');'...
                    'set([tmp.handles.AxesInput tmp.handles.AxesOutput],''ButtonDownFcn'',''boxReadyCS(gcbo,guidata(gcbo));'');'...
                    'clear tmp;']);
              % Zoom Out - resets Axes Limits, turns off DataCursor and
              % Zoom Mode.
            handles.ZoomOut=uicontrol('Parent',handles.cPanel(4),'Style','PushButton','Units','pixels',...
                'Position',[30 0 30 30],'Enable','on',...
                'CData',iczoomout,'TooltipString',zoomoutTt,'CallBack',...
                ['tmp.fig = findobj(''Tag'',''CarSim''); tmp.handles = guidata(tmp.fig);'...
                'if ishandle(tmp.handles.CursorWindow) delete(tmp.handles.CursorWindow); end;'...
                'set(tmp.handles.AxesInput,''XLim'',tmp.handles.axlims(1,1:2),''YLim'',tmp.handles.axlims(1,3:4),''ButtonDownFcn'','''');'...
                'set(tmp.handles.AxesOutput,''XLim'',tmp.handles.axlims(2,1:2),''YLim'',tmp.handles.axlims(2,3:4),''ButtonDownFcn'','''');'...
                'set(tmp.fig,''WindowButtonMotionFcn'','''',''WindowButtonUpFcn'','''',''KeyPressFcn'','''',''Pointer'',''arrow'');'...
                'clear tmp;']);

              % Data Cursor - set ButtonDownFcn of axes to cursorBarCS, and
              % figure's WindowButtonMotionFcn to ZoomPointerControlBlk
            handles.cursorPB=uicontrol('Parent',handles.cPanel(4),'Style','PushButton','Units','pixels',...
                'Position',[60 0 30 30],'Enable','on','CData',iccursor,'TooltipString',cursorTt,...
                'CallBack',['tmp = struct; tmp.handles = guidata(gcf);'...
                            'set(gcf,''PointerShapeCData'',tmp.handles.dataCursor,''WindowButtonMotionFcn'',''CarSim(''''ZoomPointerControlBlk'''',gcbo);''); '...
                            'if ishandle(tmp.handles.CursorWindow) delete(tmp.handles.CursorWindow);'...
                                'set([tmp.handles.AxesInput tmp.handles.AxesOutput],''ButtonDownFcn'','''');'...
                            'end;'...
                            'set([tmp.handles.AxesInput tmp.handles.AxesOutput],''ButtonDownFcn'',''cursorBarCS(gcbo,guidata(gcbo));'');']);

            clear iczoomin iczoomout iccursor;
    
    
    % Configure Model File ----------------------------------------

    set_param(gcs, 'stopfcn','',...                   
                   'initfcn', ['load(''' fullfile(CarSimPath, 'Data', 'TempModelParameters.mat') ''')'],...
                   'closefcn', 'CarSim(''CloseFcn'', [], [], [], [])')
    copyfile(fullfile(CarSimPath, 'Data', 'ModelParameters.Mat'), fullfile(CarSimPath, 'Data', 'TempModelParameters.Mat'), 'f')
    set_param([gcs '/Y'''''], 'NameChangeFcn', 'CarSim(''BlockNameChange'', gcb, ''DistBlock'', [], [])')
    set_param([gcs '/To CarSim GUI'], 'NameChangeFcn', 'CarSim(''BlockNameChange'', gcb, ''CarSimBlock'', [], [])')
    set_param([gcs '/To CarSim GUI/Output Conditioner'], 'NameChangeFcn', 'CarSim(''BlockNameChange'', gcb, ''OutputConditioner'', [], [])')
    set_param([gcs '/To CarSim GUI/CarSimOut'], 'StopFcn', ['CarSim(''StoreSimResults'',' num2str(fig) ', guidata(' num2str(fig) '),carSimOut); clear carSimOut;']);
    set_param([gcs '/To CarSim GUI/CarSimOut'], 'NameChangeFcn', 'CarSim(''BlockNameChange'', gcb, ''CarSimOut'', [], [])')
    try
        set_param([gcs '/SimLab DC Motor'], 'NameChangeFcn', 'CarSim(''BlockNameChange'', gcb, ''PlantBlock'', [], [])')
        handles.ExperimentSelect = 'active';
        handles.PlantBlock = [handles.SimModelName, '/SimLab DC Motor'];
        set(handles.LabButton,'Value',1);
    catch
        set_param([gcs '/Base Excitation'], 'NameChangeFcn', 'CarSim(''BlockNameChange'', gcb, ''PlantBlock'', [], [])')
        handles.ExperimentSelect = 'passive';
        handles.PlantBlock = [handles.SimModelName, '/Base Excitation'];
        set(handles.LabButton,'Value',2);
    end
    
    MARGIN = 0.05;
    HEIGHT = (1-4*MARGIN)/3;
    WIDTH = 1-3*MARGIN;
    % Configure Axes ----------------------------------------
    handles.AxesInput = axes('Parent',handles.DisplayPanel, 'fontsize', 7, 'units', 'normalized',...
                    'nextplot', 'replace', 'position', [2*MARGIN 2*MARGIN+HEIGHT WIDTH HEIGHT],'Tag','AxesInput');

    handles.AxesOutput  = axes('Parent',handles.DisplayPanel, 'fontsize', 7, 'units', 'normalized',...
                    'nextplot', 'replace', 'position', [2*MARGIN MARGIN WIDTH HEIGHT],'Tag','AxesOutput');
    
    % Prepare Lines on Axes
        handles.inAxLines = plot(handles.AxesInput,0,0,'b-',0,0,'r-',0,0,'c-','LineWidth',1.5);
        handles.outAxLines = plot(handles.AxesOutput,0,0,'b-',0,0,'r-',0,0,'c-','LineWidth',1.5);
    
        ylabel(handles.AxesOutput,'Position (m)'); xlabel(handles.AxesOutput,'Time (s)');
        ylabel(handles.AxesInput,'Position (m)'); xlabel(handles.AxesInput,'');      
    
    % Draw animation axes
    handles.AnimationAxes = axes('Parent',handles.DisplayPanel,...
                    'Tag', 'AnimationAxes',...
                     'fontsize', 7,...
                     'units', 'normalized',...
                     'ycolor', [0 0 0],...
                     'xcolor', [0 0 0],...
                     'zcolor', [0 0 0],...
                     'xtick', [],...
                     'ytick', [],...
                     'ztick', [],...
                     'xlimmode', 'manual',...
                     'ylimmode', 'manual',...
                     'box', 'on',...
                     'drawmode', 'fast',...
                     'visible', 'on',...
                     'color', get(fig, 'color'),...
                     'position', [MARGIN 3*MARGIN+2*HEIGHT 0.66*WIDTH HEIGHT]);
    
                 
    % Calculate location for Plot Select box launch buttons             
    set(handles.AxesOutput,'Units','pixels');
    set(handles.AxesInput,'Units','pixels');
    
    pos = [0 0 0 0; 0 0 0 0];
    
    pos(1,:) = get(handles.AxesInput,'Position');
    pos(2,:) = get(handles.AxesOutput,'Position');
    
    set(handles.AxesOutput,'Units','normalized');
    set(handles.AxesInput,'Units','normalized');
    
    pos(1,:) = [pos(1,1)+pos(1,3)-100 pos(1,2)+pos(1,4)+2 100 20];
    pos(2,:) = [pos(2,1)+pos(2,3)-100 pos(2,2)+pos(2,4)+2 100 20];

    % Buttons to launch plot data select boxes
    handles.ax1control = uicontrol('Style','Pushbutton','String','Setup Axes','Parent',handles.DisplayPanel,...
                                   'Units','pixels','Position',pos(1,:),...
                                   'Callback','CarSim(''PlotSelectBox'',''1'',gcf,gcbo);',...
                                   'Enable','off');
    handles.ax2control = uicontrol('Style','Pushbutton','String','Setup Axes','Parent',handles.DisplayPanel,...
                                   'Units','pixels','Position',pos(2,:),...
                                   'Callback','CarSim(''PlotSelectBox'',''2'',gcf,gcbo);',...
                                   'Enable','off');                                   

    % Initialize plot select box handles
    handles.PlotSelectBox1 = -1;
    handles.PlotSelectBox2 = -1;
    
    
                               
                               
    guidata(fig, handles);                                     

%-------------------------------------------------------------------------
% Plot Selection
%-------------------------------------------------------------------------
function PlotSelect(obj,ax,option)
    handles = guidata(obj);
    switch option
        case 'plot'

            % Returns row indexes that are to be plotted on any given graph
            SelectBoxes = findobj(get(obj,'Parent'),'Tag','PlotSelect');
            plots = [get(SelectBoxes(3),'Value') get(SelectBoxes(2),'Value')*2 get(SelectBoxes(1),'Value')*3];
            handles.(['PlotSelection' ax]) = plots(find(plots ~= 0)) + 3*get(SelectBoxes(4),'Value') -2;

            switch get(SelectBoxes(4),'Value')
                    case 1  % Position
                        ylbl = 'Position (m)';
                    case 2  % Velocity
                        ylbl = 'Velocity (m/s)';
                    case 3  % Acceleration
                        ylbl = 'Acceleration (m/s/s)';
            end

            guidata(obj,handles);    
            if handles.SimulationIsRunning
                if isequal(ax,'1')
                    ylabel(handles.AxesInput,ylbl);
                    plotCarSim(handles.PlotSelection1,handles.AxesInput);
                else
                    ylabel(handles.AxesOutput,ylbl);
                    plotCarSim(handles.PlotSelection2,handles.AxesOutput);
                end
            else
                if isequal(ax,'1')
                    ylabel(handles.AxesInput,ylbl);
                    plotCarSim(handles.PlotSelection1,handles.AxesInput,findobj('Tag','CarSim'));
                else
                    ylabel(handles.AxesOutput,ylbl);
                    plotCarSim(handles.PlotSelection2,handles.AxesOutput,findobj('Tag','CarSim'));
                end
            end
        case 'print'
            value = get(obj,'UserData');
            if isequal(ax,'1')
                handles.ExternalFigure = print2figure(handles.AxesInput,handles.ExternalFigure,value);
            else
                handles.ExternalFigure = print2figure(handles.AxesOutput,handles.ExternalFigure,value);
            end
            guidata(obj,handles);    
        otherwise
            disp('Invalid Option');
    end
            

    
    
% -------------------------------------------------------------------------
function ProgressMeter(ratio, handles)
    % ratio = 0 to 1
    set(handles.ProgressMeter, 'Position',[0 0.01 ratio 0.98],'units','Normalized');
% -------------------------------------------------------------------------
%   Changes the pointer if the cursor hovers over either time response plot
function ZoomPointerControlBlk(fig)
    handles = guidata(fig);
    ax1 = handles.AxesInput;
    ax2 = handles.AxesOutput;
    set(ax1,'Tag','AxesInput');
    set(ax2,'Tag','AxesOutput');
    axlim1 = [get(ax1,'Xlim') get(ax1,'Ylim')];
    axlim2 = [get(ax2,'Xlim') get(ax2,'Ylim')];
    pt1 = get(ax1,'CurrentPoint');
    pt1 = [pt1(1,1) pt1(1,2)];
    pt2 = get(ax2,'CurrentPoint');
    pt2 = [pt2(1,1) pt2(1,2)];
    if (pt1(1) > axlim1(1) && pt1(1) < axlim1(2) && pt1(2) > axlim1(3) && pt1(2) < axlim1(4)) || (pt2(1) > axlim2(1) && pt2(1) < axlim2(2) && pt2(2) > axlim2(3) && pt2(2) < axlim2(4))
        set(fig,'pointer','custom');
    else
        set(fig,'pointer','arrow');
    end
% -------------------------------------------------------------------------
function Scalar = CalculateScale(Signal,handles)
    % Signal = [y y' y'' z z' z'' t]
    if ~isempty(Signal)
        Z = Signal(:,4);        
        [i] = find(isnan(Z));
        Z(i) = [];
        MaxValue = handles.DefaultAnimationScale*(max(abs(Z)));
        Scalar = 0.25/MaxValue;
    else
        Scalar = 1;
    end
% -------------------------------------------------------------------------
function PlaybackButton(h, eventdata, handles, varargin)  
    disp('Playback Button Callback Function');
% -------------------------------------------------------------------------
function ControllerParametersButton(h, eventdata, handles, varargin)
    if ishandle(handles.ControllerParametersWindow)
        delete(handles.ControllerParametersWindow)
    end
    handles.ControllerParametersWindow = ModifyControllerParameters(handles); % updates tf's on return   
    guidata(handles.CarSim,handles);
% -------------------------------------------------------------------------
function ModelParametersButton(h, eventdata, handles, varargin)
    if ishandle(handles.ModelParametersWindow)
        delete(handles.ModelParametersWindow)
    end
    handles.ModelParametersWindow = ModifyModelParameters(handles.CarSimPath, handles.TFPopup); % updates tf's on return
    guidata(handles.CarSim,handles);
% -------------------------------------------------------------------------
function SetSimulationTime(h,handles)
      try 
          if str2num(get(h,'String'))< 0 || str2num(get(h,'String')) > 30
                set(h,'String',num2str(handles.SimulationTime));
          else
              handles.SimulationTime =  str2num(get(h,'String'));
              guidata(h,handles);
          end;
      catch
          set(h,'String',num2str(handles.SimulationTime)); 
      end
      
    
% -------------------------------------------------------------------------
function BlockNameChange(h, HandlesField, handles, varargin)
    if isempty(handles)
        fig = findobj(0, 'tag', 'CarSim');
        handles = guidata(fig);
    end
    handles = setfield(handles, HandlesField, h);
    guidata(handles.CarSim, handles)


% -------------------------------------------------------------------------
function LabButton(h, Value, handles, varargin)
     
    SourceSystem = 'CustomSourceBlocks';
    switch Value
        case 1
            NewBlock = 'SimLab DC Motor';
            handles.ExperimentSelect = 'active';
            set(handles.TFPopup,'Enable','on');
        case 2
            NewBlock = 'Base Excitation';
            handles.ExperimentSelect = 'passive';
            set(handles.TFPopup,'Value',2,'Enable','off');
            ShowTF(h,2,handles,[]);
    end
    handles.SpringDamper = SpringDamper([0,0], handles.AnimationLength, .5, .5,handles.AnimationAxes,handles.ExperimentSelect);
    guidata(h,handles);
    [PATHSTR,OldPlantBlock,EXT,VERSN] = fileparts(handles.PlantBlock); % Parse full pathname to get old block name
    
    open(fullfile(handles.CarSimPath, [SourceSystem '.mdl'])) % open the .mdl file with the blocks stored in it
    replace_block(handles.SimModelName, 'name', OldPlantBlock, [SourceSystem '/' NewBlock], 'noprompt') 
    bdclose(SourceSystem) % close the storage .mdl file
    set_param(handles.PlantBlock, 'namechangefcn', 'CarSim(''BlockNameChange'', gcb, ''PlantBlock'', [], [])')
    set_param(handles.PlantBlock, 'name', NewBlock)
    
% -------------------------------------------------------------------------
function ShowTF(h, Value, handles, varargin)
    % Retrieve tfs from ReturnTFs, passing handles of simulink objects require to determine the tf's   
	[Gf Gc Gp Gh] = ReturnTFs(handles.PIDController, handles.CompensatorTF, handles.FeedbackIndex, handles.CarSimPath);       
    
    % Build a structured array containing tf objects and respective names
	TFArray(1).tf = Gc;
	TFArray(1).name = 'G_C=';
	TFArray(2).tf = Gp;
	TFArray(2).name = 'G_P=';
	TFArray(3).tf = Gf;
	TFArray(3).name = 'G_F=';     
	TFArray(4).tf = Gh;
	TFArray(4).name = 'G_H=';
    
    if isempty(handles.TFAxes) % ie. if it is initializing the frame on startup...
        % initialize TF and popupmenu
        handles.TFAxes = axes('position', [0.77 0.75 0.2 0.08],'Xlim',[0 1],'Ylim',[0 1],'Visible','off');
        % create popupmenu strings
        PopupString = [{'Gc - Controller'},{'Gp - Plant'}, {'Gf - Input'}, {'Gh - Feedback'}];
        handles.TFPopup = uicontrol('style', 'popupmenu',...
                                    'string', PopupString,...
                                    'value', 2,...
                                    'backgroundcolor', [1 1 1],...
                                    'units', 'normalized',...
                                    'position', [.77 0.85 0.2 0.01],...
                                    'callback', 'CarSim(''ShowTF'', gcbo, get(gcbo, ''value''), guidata(gcbo), [])');
        guidata(handles.TFAxes, handles)
    else                          
        % Clear out any mess
        delete(get(handles.TFAxes,'Children'));
        text(0.5,0.5,poly2tex(TFArray(Value).tf.num{:},TFArray(Value).tf.den{:},TFArray(Value).name),'Parent',handles.TFAxes,...
            'Interpreter','latex','fontsize',14,'HorizontalAlignment','center','VerticalAlignment','middle');
    end

% -------------------------------------------------------------------------
function PlaySim(h, ToggleState, handles, varargin)
    if ToggleState % Play
        switch get(handles.PlaySim,'String')
            case 'Simulate Response'
                progmeter(0.1,'open');
                set([handles.ax1control handles.ax2control],'Enable','on');
                set(handles.CarSim,'pointer','arrow','WindowButtonMotionFcn','');
                progmeter(0.15);
                set(handles.PlaySim, 'string', 'Pause');
                set(handles.cPanel(4),'Visible','on');
                progmeter(0.2);
                set_param(handles.SimModelName,'StartTime','0','StopTime',num2str(handles.SimulationTime));
                set_param(handles.SimModelName, 'SimulationCommand', 'start');

                progmeter(0.25);
            case 'Continue'
                start(timerfind('Tag','plottimer'));
        end
    else  % Pause
         stop(timerfind('Tag','plottimer'));
         set(handles.PlaySim, 'string', 'Continue');
    end
% -------------------------------------------------------------------------
% Stores Simulation Results in handles guidata structure
% Called by output block in CarSimModel
function StoreSimResults(figg, handles, simData)
    if isempty(handles)
        figg = findobj(0, 'tag', 'CarSim');
        handles = guidata(fig);
    end
    progmeter(0.7);
    simData = simData';
    handles.SimData = [simData(10,:); simData(1:3:7,:) ; simData(2:3:8,:) ; simData(3:3:9,:)];
    handles.SimDataOrder = {'t','y','z', 'x', 'y''','z''','x''','y"','z"','x"'};
    guidata(figg,handles);
    
    progmeter(0.9,'close');
    plotCarSim(handles.AxesInput, handles.AxesOutput, handles.PlotSelection1, handles.PlotSelection2,...
        handles, figg);
    
% -------------------------------------------------------------------------
function StopSim(varargin)
    try
        stop(timerfind('Tag','plottimer'));
        delete(timerfind('Tag','plottimer'));
        set(findobj('Tag','CarSim'),'Resize','on','DoubleBuffer','off');
        set(findobj('Tag','PlaySim'), 'string', 'Simulate Response','Value','0');
    catch
        delete(timerfindall);
    end
    
    handles = guidata(findobj('Tag','PlaySim'));
    handles.SimulationIsRunning = 0;
    guidata(findobj('Tag','PlaySim'),handles);
% -------------------------------------------------------------------------
function CloseFcn(h, eventdata, handles, varargin)
    try
        if isempty(h) % calling from Simulink
            fig = findobj(0, 'tag', 'CarSim');
            handles = guidata(fig);
        else
            set_param(handles.SimModelName, 'closefcn', '')
            if exist(handles.SimModelName)
                bdclose(handles.SimModelName)
            end
        end
        rmpath(genpath(handles.pwd));
        closereq
    catch
        closereq
    end
%--------------------------------------------------------------------------
    
    
% -Initialize Menu---------------------------------------------------------
function handles = InitializeMenu(handles)

    handles.Menu.InputAxes = uicontextmenu;
    uimenu(handles.Menu.InputAxes, 'label', 'Edit Axes',...
                                   'callback', 'propedit(gca), plotedit(''off'')')
                                         
    set(handles.AxesInput, 'uicontextmenu', handles.Menu.InputAxes,'Tag','AxesInput')

    handles.Menu.OutputAxes = uicontextmenu;
    uimenu(handles.Menu.OutputAxes, 'label', 'Edit Axes',...
                                   'callback', 'propedit(gca), plotedit(''off'')') %set(gcf, ''windowbuttondownfcn'', plotedit(''off''))')

    set(handles.AxesOutput, 'uicontextmenu', handles.Menu.OutputAxes,'Tag','AxesOutput')

    % Menu Bar Menus
    handles.Menu.File = uimenu('Parent',handles.CarSim,'label', '&Experiment');
    uimenu('Parent',handles.Menu.File, 'label', '1: &Active Suspension', 'callback',['set( ' num2str(handles.LabButton,'%15.15f') ',''Value'',1); CarSim(''LabButton'', gcbo, 1, guidata(gcbo), [])']); 
        uimenu('Parent',handles.Menu.File, 'label', '2: &Passive Suspension', 'callback',['set( ' num2str(handles.LabButton,'%15.15f') ',''Value'',2); CarSim(''LabButton'', gcbo, 2, guidata(gcbo), [])']); 
        uimenu('Parent',handles.Menu.File, 'label', '&Close','Separator','on','callback',get(handles.CloseButton,'Callback')); 

    handles.Menu.Tools = uimenu('Parent',handles.CarSim,'label', '&Tools');
        uimenu('Parent',handles.Menu.Tools, 'label', '&Calculator','CallBack','!calc.exe;');
        cb = ['CurrentPath = pwd;',...
              'handles = guidata(gcbo);',... 
              'cd(fullfile(handles.CarSimPath, ''Tools''));',...
              'conver'];
        uimenu('Parent',handles.Menu.Tools, 'label','&Unit Conversion','CallBack',cb);

    % Help Menu
    helptxt = {'CarSim - Quarter Car Model Simulation',...
            '',...
            '1. Click on ''Model Parameters'' to modify the motor and plant parameters. ',...
            'Click on ''Control Parameters'' to modify the controller, feedback, and input. ',...
            'Given the defined parameters, the system tranfer functions can be observed by configuring the drop down menu in the top right corner.',...
            '',...
            '2. Click on ''Simulate Response'' to engage Simulink, clicking on ''Stop Simulation'' terminates simulation. ',...
            'The simulation mode (Active Suspension, Passive Suspension) can be configured from the drop down menu below the progress meter. ',...
            'Note that ''Passive Suspension'' mode is the open loop response due to base exitation without the influence of the motor.',...
            '',...
            '3. Modify the plot data on either axis by pressing the button labeled ''Axes Setup'' at the top right corner of the graphs. ',...
            'Select the data to view, or click "Print to Figure" to export the current data to an external MATLAB Figure. ',...
            'Use the ''Reuse Axes'' checkbox to save data from multiple simulations into the same MATLAB Figure. ',...
            'Use the Zoom+ and Zoom- buttons to view the plot in teh desired detail.  Use the data cursor to view precise values of data points.',...
            'Click ''Copy Point'' to copy the current cursor values onto the clipboard.'};
    handles.Menu.Tools = uimenu('Parent',handles.CarSim,'Label','Help Me','UserData',helptxt,...
            'Callback',['set(gcf,''Units'',''pixels'');'...
            'alertBoxCS(gcf,[0 0 1 1].*get(gcf,''Position'')+[300 150 -400 -250],get(gcbo,''UserData''),''Help Me'');'...
            'set(gcf,''Units'',''Normalized'');']);

%--------------------------------------------------------------------------
% Buttons
%--------------------------------------------------------------------------
function GUIControls = buildButtons(cnst,top, middle, container)

        GUIControls(1) = struct('String','Close',...
                        'Callback','CarSim(''CloseFcn'', gcbo, [], guidata(gcbo), [])',...
                        'Tag','CloseButton',...
                        'Style','PushButton',...
                        'Position',[cnst.bhspace cnst.bvspace cnst.bwidth cnst.bheight],...   			
                        'Color',[0.7529 0.7529 0.7529],...
                        'Parent',container);

        % Simulation Controls

        GUIControls(2) = struct('String',strvcat('Active Suspension','Passive Suspension'),...
                    'Callback','CarSim(''LabButton'', gcbo, get(gcbo, ''value''), guidata(gcbo), [])',...
                    'Tag','LabButton',...
                        'Style','popupmenu',...
                    'Position',[cnst.bhspace cnst.bvspace cnst.bwidth cnst.bheight],...   			
                        'Color',[0.7529 0.7529 0.7529],...
                        'Parent',middle);


        GUIControls(3) = struct('String','Stop Simulation',...
                    'Callback','CarSim(''StopSim'', gcbo, [], guidata(gcbo), [])',...
                    'Tag','StopSim',...
                        'Style','pushbutton',...
                    'Position',[cnst.bhspace 3*cnst.bvspace+2*cnst.bheight cnst.bwidth cnst.bheight],...   			
                        'Color',[0.7529 0.7529 0.7529],...
                        'Parent',middle);
   
        GUIControls(4) = struct('String','Simulate Response',...
                    'Callback','CarSim(''PlaySim'', gcbo, get(gcbo, ''value''), guidata(gcbo), [])',...
                    'Tag','PlaySim',...
                        'Style','togglebutton',...
                    'Position',[cnst.bhspace 4*cnst.bvspace+3*cnst.bheight cnst.bwidth cnst.bheight],...   			
                        'Color',[0.7529 0.7529 0.7529],...
                        'Parent',middle);
   
        % Model Control

        GUIControls(5) = struct('String','Control Parameters',...
                    'Callback','CarSim(''ControllerParametersButton'', gcbo, [], guidata(gcbo), [])',...
                    'Tag','ControlParameters',...
                        'Style','pushbutton',...
                    'Position',[cnst.bhspace cnst.bvspace cnst.bwidth cnst.bheight],...   			
                        'Color',[0.7529 0.7529 0.7529],...
                        'Parent',top);

        GUIControls(6) = struct('String','Model Parameters',...
                    'Callback','CarSim(''ModelParametersButton'', gcbo, [], guidata(gcbo), [])',...
                    'Tag','ModelParameters',...
                        'Style','pushbutton',...
                    'Position',[cnst.bhspace 2*cnst.bvspace+cnst.bheight cnst.bwidth cnst.bheight],...   			
                        'Color',[0.7529 0.7529 0.7529],...
                        'Parent',top);

         GUIControls(7) = struct('String','3',...
                    'Callback','CarSim(''SetSimulationTime'', gcbo, guidata(gcbo))',...
                    'Tag','SimulationTime',...
                        'Style','edit',...
                    'Position',[cnst.bhspace+cnst.bwidth*0.7 3*cnst.bvspace+2*cnst.bheight cnst.bwidth*0.3 cnst.bheight],...   			
                        'Color',[1 1 1],...
                        'Parent',top);
        GUIControls(8) = struct('String','Enter Simulation Time',...
                    'Callback','',...
                    'Tag','SimLength',...
                        'Style','text',...
                    'Position',[cnst.bhspace-10 3*cnst.bvspace+2*cnst.bheight cnst.bwidth*0.7+10 cnst.bheight],...   			
                        'Color',[0.9 0.9 0.9],...
                        'Parent',top);

%-----------------------------------------------------------------------
%-------PROGRESS-METER--------------------------------------------------
%-----------------------------------------------------------------------
function progmeter(varargin)

   % Manages the opening progress meter
            
            persistent fig
            persistent bar
            if nargin == 1
                progress = varargin{1};
                set(bar,'Position',[ 0 0 progress 1]);
            else
                progress = varargin{1};
                command = varargin{2};
                switch command
                    case 'close'
                        close(fig);
                        clear persistent fig bar;
                    case 'open'
                         fig = figure('Menubar','none',...
                                        'Units','Normalized',...
                                        'Name','Loading...',...
                                        'Resize','off',...
                                        'NumberTitle','off',...
                                        'BackingStore','off',...
                                        'Color',[0.9 0.9 0.9],...
                                        'Position',[0.45 0.45 0.1 0.05],...
                                        'Pointer','watch',...
                                        'WindowStyle','modal');
                    
                        set(fig,'Units','pixels');
                        progpos = get(fig,'Position');
                        set(fig,'Position',[progpos(1:2) 200 80]);
                        bar = uipanel('Parent',fig,...
                                            'Units','pixels',...
                                            'BorderType','line',...
                                            'ForegroundColor','k',...
                                            'BorderWidth',2,...
                                            'BackgroundColor',[1 1 1],...
                                            'Position',[10 10 180 60],...
                                            'Title',''...
                                            );
                        bar = uipanel('Parent',bar,...
                                            'Units','normalized',...
                                            'BorderType','none',...
                                            'BackgroundColor','b',...
                                            'Position',[0 0 progress 1],...
                                            'Title',''...
                                            );
                end
            end
            drawnow;
%-----------------------------------------------------------------------
%--END-OF-PROGRESS-METER------------------------------------------------
%-----------------------------------------------------------------------

%-----------------------------------------------------------------------
%--PLOT-SELECT-BOX-FUNCTION---------------------------------------------
%-----------------------------------------------------------------------
function PlotSelectBox(ax,fig,button)
% Sets up the plot selection box for either axes
%    ax :  '1'  or '2'
%   fig:  handle of figure
%   button:  handle to the pushbutton that launched the window

    pos = get(button,'Position');

    handles = guidata(fig);

    width = 100;
    spacing = 1;
    
    if ishandle(handles.(['PlotSelectBox' ax]))
        delete(handles.(['PlotSelectBox' ax]));
    end
    
    selection = handles.(['PlotSelection' ax]);
    if length(selection) ~= 0
        selection = selection - 1;
        selected = [0 0 0 0];
        if mod(selection,4) == selection
            selected(1) = 1;
        elseif mod(selection,7) == selection
            selected(1) = 2;
        elseif mod(selection,10) == selection
            selected(1) = 3;
        else

        end

        idx = mod(selection,3)+1;
        idx(find(idx ==1)) = 4;
        selected(idx) = 1;
    else
        selected = [1 0 0 0];
    end

    
    handles.(['PlotSelectBox' ax]) = uipanel('Parent',handles.DisplayPanel,...
                                            'Units','pixels',...
                                            'BorderType','Beveledout',...
                                            'Position',[pos(1) pos(2)-145 width 140]);
    uicontrol('Parent',handles.(['PlotSelectBox' ax]),...
                            'Style','text',...
                            'Units','Pixels',...
                            'Position',[spacing 120+spacing width-2*spacing 20-2*spacing],...
                            'BackgroundColor',[0.9 0.9 1],...
                            'Enable','off',...
                            'String',['Axis ' ax],...
                            'ButtonDownFcn',['hoverBoxCS(' num2str(fig) ',' num2str(handles.(['PlotSelectBox' ax]),'%15.15f') ',gcbo);']);
    uicontrol('Parent',handles.(['PlotSelectBox' ax]),...
                'Units','pixels',...
                'Position',[width-19 121 18 18],...
                'Style','PushButton',...
                'String','X',...
                'Callback',['delete(' num2str(handles.(['PlotSelectBox' ax]),'%15.15f') ');']);

    fillerbox = uicontrol('Parent',handles.(['PlotSelectBox' ax]),...
                                            'Units','pixels',...
                                            'Style','text',...
                                            'String','',...
                                            'Position',[0 0 width 120]);
    
    inputAxisSelect = uipanel('Parent',handles.(['PlotSelectBox' ax]),...
                                            'Units','pixels',...
                                            'BorderType','beveledout',...
                                            'Position',[0 0 width 120]);
                                            
    inputAxisSelectBox(1) = uicontrol('Parent',inputAxisSelect,...
                                            'Style','popupmenu',...
                                            'String',{'Position','Velocity','Acceleration'},...
                                            'Units','pixels',...
                                            'Position',[spacing 100+spacing width-2*spacing 20-2*spacing],...
                                            'BackGroundColor',[1 1 1],...
                                            'Tag','PlotSelect',...
                                            'Value',selected(1),...
                                            'Callback',['CarSim(''PlotSelect'',gcbo,''' ax ''',''plot'');']);
                                        
    inputAxisSelectBox(2) = uicontrol('Parent',inputAxisSelect,...
                                            'Style','checkbox',...
                                            'Units','Pixels',...
                                            'String','Y',...
                                            'Value',selected(2),...
                                            'Position',[spacing 80+spacing width-2*spacing 20-2*spacing],...
                                            'Tag','PlotSelect',...
                                            'Callback',['CarSim(''PlotSelect'',gcbo,''' ax ''',''plot'');']);
    inputAxisSelectBox(3) = uicontrol('Parent',inputAxisSelect,...
                                            'Style','checkbox',...
                                            'Units','Pixels',...
                                            'String','Z',...
                                            'Value',selected(3),...
                                            'Position',[spacing 60+spacing width-2*spacing 20-2*spacing],...
                                            'Tag','PlotSelect',...
                                            'Callback',['CarSim(''PlotSelect'',gcbo,''' ax ''',''plot'');']);
    inputAxisSelectBox(4) = uicontrol('Parent',inputAxisSelect,...
                                            'Style','checkbox',...
                                            'Units','Pixels',...
                                            'String','X',...
                                            'Value',selected(4),...
                                            'Position',[spacing 40+spacing width-2*spacing 20-2*spacing],...
                                            'Tag','PlotSelect',...
                                            'Callback',['CarSim(''PlotSelect'',gcbo,''' ax ''',''plot'');']);
    
    button = uicontrol('Style','pushbutton',...
                        'String','Print To Figure',...
                        'Parent',inputAxisSelect,...
                        'UserData',0,...
                        'Position',[spacing 20+spacing width-2*spacing 20-2*spacing],...
                        'Callback',['CarSim(''PlotSelect'',gcbo,''' ax ''',''print'');']);
                                        
    reuse = uicontrol('String','Reuse Axes',...
                        'Callback','set(get(gcbo,''UserData''),''UserData'',get(gcbo,''Value''));',...
                        'Style','CheckBox',...
                        'Position',[spacing spacing width-2*spacing 20-2*spacing],...
                        'Parent',inputAxisSelect,...
                        'Value',0,...
                        'UserData',button);
    guidata(fig,handles);

%-------------------------------------------------------------------------
%---PRINT-2-FIGURE--------------------------------------------------------
%-------------------------------------------------------------------------
 function axHandle = print2figure(copyAxes,axHandle,reuse)
% print2figure
%   This function is called by the "Print To Figure" button.
%   Handles the request based on whether the "Reuse Axes" checkbox is
%   selected.
if ~ishandle(axHandle) || ~(reuse);
    if ishandle(axHandle)
        fig = get(axHandle,'Parent');
        delete(axHandle);
    else
        fig = figure;
    end

    set(fig,'Name',['Response plot'],'NumberTitle','off');
    axHandle = axes('Parent',fig);
    set(axHandle,'Units','Normalized','Position',[0.1 0.1 0.8 0.8],'Xlim',get(copyAxes,'Xlim'),'Ylim',get(copyAxes,'Ylim'),'GridLineStyle',':','XGrid','on','YGrid','on');
    copyobj([get(copyAxes,'ylabel')],axHandle);
    title(axHandle,'CarSim - Time Response Plot');
    xlabel(axHandle,'Time (s)');
    kids = get(copyAxes,'Children');
    kids = findobj(kids,'type','line');
    currPosDat = get(kids,'YData');

    for ii = 1:length(currPosDat)
        if length(currPosDat{ii}) > 2
            newkid = copyobj(kids(ii), axHandle);
            set(newkid,'EraseMode','normal');
        end
    end
    legend(axHandle,'on');

elseif ishandle(axHandle) && (reuse);
        legend(axHandle,'off');
    oldlims = [get(axHandle,'Xlim') get(axHandle,'YLim')];
    newlims = [get(copyAxes,'Xlim') get(copyAxes,'Ylim')];
    
    newlims = [min(oldlims(1),newlims(1)) max(oldlims(2),newlims(2)) min(oldlims(3),newlims(3)) max(oldlims(4),newlims(4))];
    
    set(axHandle,'XLimMode','manual','YLimMode','manual','Xlim',newlims(1:2),'Ylim',newlims(3:4));    
    
    kids = findobj(copyAxes,'type','line');
    currPosDat = get(kids,'YData');

    for ii = 1:length(currPosDat)
        if length(currPosDat{ii}) > 2
            newkid = copyobj(kids(ii), axHandle);
            set(newkid,'EraseMode','normal');
        end
    end
    
    kids = findobj(axHandle,'type','line');
    corder = get(axHandle,'ColorOrder'); corder = [corder(1,:);corder(3,:);corder(2,:);corder(4:end,:)];
    
    for ii = 0:length(kids)-1
        set(kids(length(kids)-ii),'color',corder(mod(ii,length(corder(:,1)))+1,:));
    end
    legend(axHandle,'on');
    
end

axes(axHandle);
    
%-------------------------------------------------------------------------
%--Transfer Function Calculations-----------------------------------------
%-------------------------------------------------------------------------
function [G_f, G_c, G_p, G_h] = ReturnTFs(PIDController, CompensatorTF, FeedbackIndex, CarSimPath)
    % Purpose: Returns the system transfer functions
    % Inputs:
    %   PID = [P I D];
    %   CompTF = tf object;
    %   FB = z, z'' or x'' (string)
    %   CarSimPath = path to simulation parent directory (to load .mat file from
    %                'Data' folder)
    % Outputs:
    %   G_f = pre-calculated TF
    %   G_c = (PID transfer fnc)*(CompTf)
    %   G_p = pre-calculated TF
    

    Kp = str2num(get_param(PIDController, 'P'));
    Kd = str2num(get_param(PIDController, 'D'));
    Ki = str2num(get_param(PIDController, 'I'));
    if Ki == 0
        PIDTF = tf([Kd Kp], [1]);
    else
        PIDTF = tf([Kd Kp Ki], [1 0]);
    end
    
    
    num = str2num(get_param(CompensatorTF, 'denominator'));
    den = str2num(get_param(CompensatorTF, 'numerator'));
    CompTF = tf(num, den);
    
    G_c = PIDTF*CompTF;

    load(fullfile(CarSimPath, 'Data', 'TempModelParameters.mat'))
    
    J = M*r^2+Jm;
	B = c*r^2+Jm;
	K = k*r^2;

	a2 = 1;
	a1 = (B*Ra+Km*Kb)/(Ra*J);
	a0 = K/J;
    
    Index = str2double(get_param(FeedbackIndex, 'value'));
    if isequal(Index, 1)
        Feedback = 'z';
        G_p = tf([(M*r^2)/J], [a2 a1 a0]);
        G_h = tf([Km*Kamp*Ks/(M*r*Ra)], [1]);
        G_f = tf([-1],[1]);
        
    elseif isequal(Index, 2)
        Feedback = 'z''''';
        G_p = tf([(M*r^2)/J 0 0], [a2 a1 a0]);
        G_h = tf([Km*Kamp*Ks/(M*r*Ra)], [1]);
        G_f = tf([-1],[1]);
        
    elseif isequal(Index, 3)
        Feedback = 'x''''';
        G_p = tf([1-(M*r^2)/J a1 a0], [a2 a1 a0]);
        G_h = tf([Km*Kamp*Ks*r/(Ra*J) 0 0], [1-(M*r^2)/J a1 a0]);
        G_f = tf([1],[1]);
        
    end
    
%                     +
%  Y'' --->[ Gf ] ---->o----->[ Gp ]-----------> Z, Z'', or X''
%                     -|                    |
%                      |                    |
%                      |--[ Gc ]<--[ Gh ]<--|