function varargout = ModifyControllerParameters(varargin)

if nargin == 1   
    fig = figure('menubar', 'none',... 
                 'units', 'normalized',...
                 'numbertitle', 'off',...
                 'name', 'Controller Parameters',...
                 'closerequestfcn', 'ModifyControllerParameters(''CloseButton'', gcbo, [], guidata(gcbo), [])',...
                 'position', [0.4316    0.4362    0.4    0.25],...
                 'windowstyle', 'normal',...
                 'resize', 'off');
    %BlockNames = varargin{2};          
    CarSimHandles = varargin{1};
    
    
%     if isempty(varargin{4})
%         load(fullfile(varargin{3}, 'Data', 'ControllerParameters.mat'))
%     else
%         ControllerParameters = varargin{4};
%     end    
    
    InitializeGui(CarSimHandles)

    % Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
    % modifiy handles structure
    %handles.Disturbance = CarSimHandles.Disturbance;
    handles.SimModelName = CarSimHandles.SimModelName;
    handles.DistBlock = CarSimHandles.DistBlock;
    handles.CarSimBlock = CarSimHandles.CarSimBlock;
    handles.OutputConditioner = CarSimHandles.OutputConditioner;
    handles.PIDController = CarSimHandles.PIDController;
    handles.CarSimPath = CarSimHandles.CarSimPath;
    handles.CompensatorTF = CarSimHandles.CompensatorTF;
    handles.FeedbackIndex = CarSimHandles.FeedbackIndex;
    handles.TFPopup = CarSimHandles.TFPopup;
    
    handles.Selection = 1;
%     handles.ControllerParameters = ControllerParameters; 
%     handles.ControllerParameters2 = ControllerParameters; clear ControllerParameters; 
%     handles.CarSimPath = varargin{3};
    
    guidata(fig, handles);
    
    
    InputSelection([], get(handles.InputSelection, 'value'), handles, [])
    
%     uiwait(fig)    
%     figure(fig)
%     handles = guidata(fig);
	if nargout > 0
		varargout{1} = [fig];
	end
%     closereq
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
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
% ____________________________________________________________________________________________________________________________

function InitializeGui(handles)

	Position = [0.0305    0.7612    0.4280    0.1251;
                0.0305    0.6314    0.4280    0.0948;
                0.0305    0.4958    0.4280    0.1251;
                0.0305    0.3707    0.4280    0.0948;
                0.0305    0.2304    0.4280    0.1251;
                0.0305    0.0322    0.1945    0.1488;
                0.2625    0.0322    0.1945    0.1488;
                0.0158    0.0322    0.4565    0.1200;
                0.5058    0.0322    0.4900    0.1200];
            
    backgroundcolor = get(gcf, 'color');

    uicontrol('style', 'frame',...
              'units', 'normalized',...
              'backgroundcolor', backgroundcolor,...
              'position', [0.0158    0.200    0.4565    0.74])
    uicontrol('style', 'text',...
              'units', 'normalized',...
              'backgroundcolor', backgroundcolor,...
              'fontsize', 8,...
              'position', [0.03, 0.2+.67, .25 .1],...
              'string', 'DISTURBANCE')
    uicontrol('style', 'frame',...
              'units', 'normalized',...
              'backgroundcolor', backgroundcolor,...
              'position', [0.0158+.49    0.20    0.49    0.74])
%     uicontrol('style', 'frame',...
%               'units', 'normalized',...
%               'backgroundcolor', backgroundcolor,...
%               'position', [0.0158+.49+0.49    0.20    0.001    0.74])
%     uicontrol('style', 'frame',...
%               'units', 'normalized',...
%               'backgroundcolor', backgroundcolor,...
%               'position', [0.0158+.49    0.20    0.001    0.74])

    uicontrol('style', 'text',...
              'units', 'normalized',...
              'backgroundcolor', backgroundcolor,...
              'fontsize', 8,...
              'position', [0.03+.49, 0.2+.67, .25 .1],...
              'string', 'COMPENSATOR')
    
    Data = get_param(handles.DistBlock, 'userdata');
    if isempty(Data)
        Data.Type = 1;
        Data.Amp = '1';
        Data.Time = '0';
    end
        

    uicontrol('style', 'popupmenu',...
          'units', 'normalized',...
          'string', [{'Step'}; {'Impulse'}; {'Sin'}; {'URP (Rounded Pulse)'}; {'Rounded Step'}; {'Random'}],...
          'tag', 'InputSelection',...
          'backgroundcolor', [1 1 1],...
          'position', Position(1,:),...
          'value', Data.Type,...
          'callback', 'ModifyControllerParameters(''InputSelection'', gcbo, get(gcbo, ''value''), guidata(gcbo), [])')
      
    uicontrol('style', 'text',...
          'units', 'normalized',...
          'string', 'Amplitude',...
          'horizontalalignment', 'left',...
          'tag', 'AmplitudeTitle',...
          'backgroundcolor', backgroundcolor,...
          'position', Position(2,:))
      
    uicontrol('style', 'edit',...
          'units', 'normalized',...
          'string', Data.Amp,...
          'horizontalalignment', 'left',...
          'tag', 'Amplitude',...
          'backgroundcolor', [1 1 1],...
          'position', Position(3,:),...
          'callback', 'ModifyControllerParameters(''CheckInput'', gcbo, get(gcbo, ''string''), guidata(gcbo), [])')

    uicontrol('style', 'text',...
          'units', 'normalized',...
          'string', 'Step Time (s)',...
          'horizontalalignment', 'left',...
          'backgroundcolor', backgroundcolor,...
          'tag', 'TimeFreqTitle',...
          'position', Position(4,:))
      
    uicontrol('style', 'edit',...
          'units', 'normalized',...
          'string', Data.Time,...
          'horizontalalignment', 'left',...
          'tag', 'TimeFreq',...
          'backgroundcolor', [1 1 1],...
          'position', Position(5,:),...
          'callback', 'ModifyControllerParameters(''CheckInput'', gcbo, get(gcbo, ''string''), guidata(gcbo), [])')
      
    uicontrol('style', 'pushbutton',...
              'units', 'normalized',...
              'string', 'Apply',...
              'tooltipstring', 'Apply and close',...-
              'backgroundcolor', backgroundcolor,...
              'tag', 'ApplyButton',...
              'position', Position(8,:),...
              'callback', 'ModifyControllerParameters(''ApplyButton'', gcbo, [], guidata(gcbo), [])')
    
    uicontrol('style', 'pushbutton',...
              'units', 'normalized',...
              'string', 'Close',...
              'tooltipstring', 'Close without applying',...
              'backgroundcolor', backgroundcolor,...
              'tag', 'CloseButton',...
              'position', Position(9,:),...
              'callback', 'ModifyControllerParameters(''CloseButton'', gcbo, [], guidata(gcbo), [])')
          
          
    uicontrol('style', 'popupmenu',...
              'units', 'normalized',...
              'string', [{'z'},{'z'''''},{'x'''''}],...
              'tooltipstring', 'Choose feedback loop parameter',...
              'backgroundcolor', [1 1 1],....
              'position', [0.7415    0.7813    0.2415    0.1042],...
              'tag', 'FeedbackSelection',...
              'value', str2double(get_param(handles.FeedbackIndex, 'value')))
    uicontrol('style', 'text',...
          'units', 'normalized',...
          'string', 'Feedback:',...
          'position', [0.5171    0.7760    0.2146    0.0938],...
          'horizontalalignment', 'right',...
          'backgroundcolor', backgroundcolor)
      
    uicontrol('style', 'text',...
          'units', 'normalized',...
          'string', '[P I D]:',...
          'position', [0.5171    0.6300   0.2146    0.0938],...
          'horizontalalignment', 'right',...
          'backgroundcolor', backgroundcolor)      
    uicontrol('style', 'text',...
          'units', 'normalized',...
          'string', 'Compensator TF:',...
          'position', [0.5171    0.4792    0.2146    0.0938],...
          'horizontalalignment', 'right',...
          'backgroundcolor', backgroundcolor)  
    
    PID = ['[' get_param(handles.PIDController, 'P') ' ' get_param(handles.PIDController, 'I') ' ' get_param(handles.PIDController, 'D') ']'];
    
    uicontrol('style', 'edit',...
            'units', 'normalized',...
            'string', PID,...
            'horizontalalignment', 'right',...
            'tag', 'PIDValue',...
            'backgroundcolor', [1 1 1],...
            'position', [0.7415    0.6354    0.2415    0.1042])
        
    wkspace = evalin('base','whos');    
    for i = length(wkspace):-1:1
        if ~isequal(wkspace(i).class, 'zpk') & ~isequal(wkspace(i).class, 'tf')
            wkspace(i) = [];
        end
    end
    TFString = [{'None'}; [{wkspace.name}]'];
    Name = get_param(handles.CompensatorTF, 'userdata');
    Index = [];
    for i = 1:length(TFString)
        if isequal(char(TFString(i)), Name) | isequal(Name, '')
            Index = i;
            break
        end
    end
    if isempty(Index)
        TFString = [TFString; {Name}];
        Index = length(TFString);
    end
    
    uicontrol('style', 'popupmenu',...
              'units', 'normalized',...
              'string', TFString,...
              'value', Index,...
              'tooltipstring', 'Choose compensator transfer function',...
              'position', [0.7415    0.4792    0.2415    0.1042],...
              'backgroundcolor', [1 1 1],...
              'tag', 'CompensatorSelection')
 
    uicontrol('style', 'pushbutton',...
              'units', 'normalized',...
              'string', 'SISOTool',...
              'tooltipstring', 'Export to workspace',...-
              'tag', 'ExportButton',...
              'backgroundcolor', backgroundcolor,...
              'position', [0.5220    0.2304    0.4585    0.2031],...
              'callback', 'ModifyControllerParameters(''ExportButton'', gcbo, [], guidata(gcbo), [])')
     

% -------------------------------------------------------------------------
function InputSelection(h, SelectionIndex, handles, varargin)
    if isequal(SelectionIndex, 1) % STEP        
        TimeString = 'Step Time (s)';
        TimeValue = '0';
        AmpString = 'Amplitude (m/s^2)';
        AmpValue = '1';
        
    elseif isequal(SelectionIndex, 2) % IMPULSE        
        TimeString = 'Duration (s)';
        TimeValue = '0.01';
        AmpString = 'Amplitude (m/s^2)';
        AmpValue = '1';
        
    elseif isequal(SelectionIndex, 3) % SIN
        TimeString = 'Frequency (rad/s)';
        TimeValue = '5';
        AmpString = 'Amplitude (m/s^2)';
        AmpValue = '1';
        
    elseif isequal(SelectionIndex, 4)|isequal(SelectionIndex, 5) % Unidirectional Rounded Pulse (URP) / Rounded Displacement
        TimeString = 'Duration (s)';
        TimeValue = '0.5';
        AmpString = 'Amplitude (m)';
        AmpValue = '0.1';
        
    elseif isequal(SelectionIndex, 6)
        TimeString = 'Sample Time (s)';
        TimeValue = '0.1';
        AmpString = 'Variance';
        AmpValue = '1';
    end
    set(handles.TimeFreqTitle, 'string', TimeString)
    set(handles.AmplitudeTitle, 'string', AmpString)
    if ~isempty(h) % ie, not initializing
        set(handles.TimeFreq, 'string', TimeValue)
        set(handles.Amplitude, 'string', AmpValue)
    end

% -------------------------------------------------------------------------
function CheckInput(h, Value, handles, varargin)
    [Num, Status] = str2num(Value);
    if ~Status % ie. Status = 0, then value is not numeric
        set(h, 'string', '1')
    elseif Num < 0 & isequal(h, handles.TimeFreq)
        set(h, 'string', '1')
    end

% -------------------------------------------------------------------------
function ApplyButton(h, eventdata, handles, varargin)
        Status = ApplyValues(h, handles);
        %uiresume(gcf)
        if Status
            CloseButton(h, [], handles, [])
        end
        
        
% -------------------------------------------------------------------------   
function ExportButton(h, eventdata, handles, varargin)
    Status = ApplyValues(h, handles);
    %uiresume(gcf)
    if Status
        CloseButton(h, [], handles, [])
        
        % Launch sisotool
        OPTIONS.Location = 'feedback';
        OPTIONS.Sign = -1;
        [Gf Gc Gp Gh] = ReturnTFs(handles.PIDController, handles.CompensatorTF, handles.FeedbackIndex, handles.CarSimPath);
        sisotool(Gp, Gc, Gh, Gf, OPTIONS)
        % SISOTOOL(G,C,H,F)
    end
    
        
% ------------------------------------------------------------------------- 
function Status = ApplyValues(h, handles)
        % UPDATE CONTROLLER
        Status = 0; % Default fail status
        set_param(handles.FeedbackIndex, 'value', num2str(get(handles.FeedbackSelection, 'value')))
        try
            PID = evalin('base', get(handles.PIDValue, 'string'));
            if ~isequal(size(PID), [1 3]) | ~isnumeric(PID)
                errordlg('Invalid PID values.')
                return
            else
                set_param(handles.PIDController, 'P', num2str(PID(1)), 'I', num2str(PID(2)), 'D', num2str(PID(3)))
            end
        catch
            errordlg([{'Invalid PID values.'}; {lasterr}])
            return
        end
        try
            CompIndex = get(handles.CompensatorSelection, 'value');
            CompList = get(handles.CompensatorSelection, 'string');
            if isequal(CompIndex, 1)
                numerator = '[1]';
                denominator = '[1]';
                Name = 'None';
            else
                Compensator = tf(evalin('base', char(CompList(CompIndex))));
                numerator = get(Compensator, 'num');
                numerator = ['[' num2str(numerator{1}) ']'];
                denominator = get(Compensator, 'den');
                denominator = ['[' num2str(denominator{1}) ']'];
                Name = char(CompList(CompIndex));
            end
            set_param(handles.CompensatorTF, 'denominator', denominator, 'numerator', numerator, 'userdata', Name)
        catch
            errordlg([{'Invalid compensator transfer function'}; {lasterr}])
            set(handles.CompensatorSelection, 'value', 1)
            set_param(handles.CompensatorTF, 'denominator', '[1]', 'numerator', '[1]', 'userdata', 'None')
            return
        end
       
        % UPDATE INPUT:
        [PATHSTR,DisturbanceName,EXT,VERSN] = fileparts(handles.DistBlock);
        SelectionIndex = get(handles.InputSelection, 'value');
        IC = '0'; % y' initial condition for integration of y''
        Time = get(handles.TimeFreq, 'string');
        Amp = get(handles.Amplitude, 'string');
        if isequal(SelectionIndex, 1) % STEP
            replace_block(handles.SimModelName, 'name', DisturbanceName, 'step', 'noprompt')
            set_param(handles.DistBlock,... 
                      'before', '0',... 
                      'after', Amp,... 
                      'sampletime', '0',...
                      'time', Time)
        elseif isequal(SelectionIndex, 2) % IMPULSE
            replace_block(handles.SimModelName, 'name', DisturbanceName, 'step', 'noprompt')
            set_param(handles.DistBlock,...
                       'before', Amp,... 
                       'after', '0',... 
                       'sampletime', '0',...
                       'time', Time)
        elseif isequal(SelectionIndex, 3) % SIN
            replace_block(handles.SimModelName, 'name', DisturbanceName, 'sin', 'noprompt')
            set_param(handles.DistBlock,... 
                       'amplitude', Amp,... 
                       'sampletime', '0',...
                       'frequency', Time)
            IC = num2str(-str2num(get(handles.Amplitude, 'string'))/str2num(get(handles.TimeFreq, 'string')));
        elseif isequal(SelectionIndex, 4)|isequal(SelectionIndex, 5) % URP URPBlock/URP
            % Note that user inputs the timespan:
            % f = g*w/(2*pi)
            % T = 1/f; T = (2*pi)/gw
            % gw = 2*pi/T
            if isequal(SelectionIndex,4)
                NewBlock = 'CustomSourceBlocks/URP';
            else
                NewBlock = 'CustomSourceBlocks/RD';
            end
            open(fullfile(handles.CarSimPath, 'CustomSourceBlocks.mdl'))
            replace_block(handles.SimModelName, 'name', DisturbanceName, NewBlock, 'noprompt')
            bdclose('CustomSourceBlocks')
            
            Time = num2str(2*pi/str2num(get(handles.TimeFreq, 'string')));
            Amp = get(handles.Amplitude, 'string');
            set_param(handles.DistBlock,... 
                       'X', Amp,... 
                       'sampletime', '0',...
                       'gw', Time,...
                       'Output', 'Acceleration')     
        elseif isequal(SelectionIndex, 6) % White Noise
            replace_block(handles.SimModelName, 'name', DisturbanceName, 'RandomNumber', 'noprompt')
            set_param(handles.DistBlock,... 
                       'mean', '0',... 
                       'sampletime', Time,...
                       'Variance', Amp)    
        end
        Data.Type = SelectionIndex;
        Data.Time = get(handles.TimeFreq, 'string');
        Data.Amp = get(handles.Amplitude, 'string');
        
        set_param(handles.DistBlock, 'NameChangeFcn', 'CarSim(''BlockNameChange'', gcb, ''DistBlock'', [], [])',...
                                     'userdata', Data)        
        set_param(handles.OutputConditioner,...
                      'IC_3', IC) % Set the Y' initial condition for integration of Y''
%         handles.Disturbance.Type = SelectionIndex;
%         handles.Disturbance.Amp = get(handles.Amplitude, 'string');
%         handles.Disturbance.Time = get(handles.TimeFreq, 'string');

        guidata(h, handles)     
        Status = 1;



% -------------------------------------------------------------------------
function CloseButton(h, eventdata, handles, varargin)
    %uiresume(gcf)
    h = handles.TFPopup;
    closereq
    CarSim('ShowTF', [], get(h, 'value'), guidata(h), [])
    
% % -------------------------------------------------------------------------
% function ExportButton(h, eventdata, handles, varargin)
%     ParameterSelection(h, get(handles.ParameterSelection, 'value'), handles, varargin)
%     handles = guidata(h);
%     P = handles.ControllerParameters(1).Value;
%     I = handles.ControllerParameters(2).Value;
%     D = handles.ControllerParameters(3).Value;
%     DD = handles.ControllerParameters(4).Value;
%     assignin('base', 'Kp', P)
%     assignin('base', 'Ki', I)
%     assignin('base', 'Kd', D)
%     assignin('base', 'Kdd', DD)
%     
    % TEMPLATE FUNCTION --------------------------------------------------------------------
% function varargout = listbox1_Callback(h, eventdata, handles, varargin)



        
        