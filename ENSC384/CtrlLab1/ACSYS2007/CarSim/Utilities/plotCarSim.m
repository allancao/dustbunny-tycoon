% plotCarSim
% - plotCarSim
%       Prepares the Axes for the animated YT Time Response plot
%
function plotCarSim(varargin)
    if nargin == 6
        
        axes1 = varargin{1};
        axes2 = varargin{2};
        plots1 = varargin{3};
        plots2 = varargin{4};
        handles = varargin{5};
        fig = varargin{6};
        
        set(fig,'Resize','off','DoubleBuffer','on');

        % Set Up Axes Limits
        xlims = [handles.SimData(1,1) handles.SimData(1,end)];
        ylims1 = YAxisLims(handles.SimData(plots1,:));
        ylims2 = YAxisLims(handles.SimData(plots2,:));

        handles.axlims = [xlims ylims1; xlims ylims2];
        
%         kiddies = [get(axes1,'Children') ; get(axes2,'Children')]
%         
%         if ~isempty(kiddies)
%             delete(kiddies);
%         end
        xlbl1 = get(get(axes1,'xlabel'),'String');
        xlbl2 = get(get(axes2,'xlabel'),'String');
        ylbl1 = get(get(axes1,'ylabel'),'String');
        ylbl2 = get(get(axes2,'ylabel'),'String');
        
        set(axes1,'NextPlot','replace');
        set(axes2,'NextPlot','replace');       
        % Create Plots
        handles.inAxLines = plot(axes1,0,0,'b-',0,0,'r-',0,0,'c-','LineWidth',1.5);
        handles.outAxLines = plot(axes2,0,0,'b-',0,0,'r-',0,0,'c-','LineWidth',1.5);

        handles.SimulationIsRunning = 1;        
        CarSim('ProgressMeter',0.001, handles);
        guidata(fig, handles);
        
        set(axes1,'XLimMode','manual','YLimMode','manual',...
                                'XGrid','on','YGrid','on','GridLineStyle',':',...
                                'XLim',xlims,'Ylim',ylims1,'Tag','AxesInput');
        set(axes2,'XLimMode','manual','YLimMode','manual','Tag','AxesOutput',...
                                'XGrid','on','YGrid','on','GridLineStyle',':',...
                                'XLim',xlims,'Ylim',ylims2);
        ylabel(axes1,ylbl1); xlabel(axes1,xlbl1); ylabel(axes2,ylbl2); xlabel(axes2,xlbl2); 
        if ~isempty(handles.PlotSelection1)        
            legend(axes1,handles.SimDataOrder{handles.PlotSelection1},'Location','NorthWest');
        end
        if ~isempty(handles.PlotSelection2)
            legend(axes2,handles.SimDataOrder{handles.PlotSelection2},'Location','NorthWest');
        end
        pTimerPeriod = round(1000/15)/1000;
        pTimer = timer('Period',pTimerPeriod,'BusyMode','drop','TimerFcn',...
            'plotCarSim(timerfind(''Tag'',''plottimer''));','UserData',1,...
            'ErrorFcn','stop(timerfind(''Tag'',''plottimer'')); delete(timerfind(''Tag'',''plottimer''));',...
            'ExecutionMode','fixedDelay','Tag','plottimer');

        start(pTimer);
        
    elseif nargin == 3
        % Just plot the data onto the given axes
        axes1 = varargin{2};
        plots1 = varargin{1};
        fig = varargin{3};
        delete(findobj('Tag','CursorDot'));
        
        set(fig,'Pointer','arrow','WindowButtonMotionFcn','','KeyPressFcn','');
        

        handles = guidata(fig);
        
        set(fig,'Resize','on');

        % Set Up Axes Limits
        xlims = [handles.SimData(1,1) handles.SimData(1,end)];
        ylims1 = YAxisLims(handles.SimData(plots1,:));


        
        xlbl1 = get(get(axes1,'xlabel'),'String');
        ylbl1 = get(get(axes1,'ylabel'),'String');
        
        set(axes1,'NextPlot','replace');

        % Create Plots    
        switch length(plots1)
            case 0
                    lines = plot(axes1,0,0,'b-',0,0,'r-',0,0,'c-','LineWidth',1.5,'EraseMode','xor');
            case 1
                    lines = plot(axes1,handles.SimData(1,:),handles.SimData(plots1(1),:),'b-',0,0,'r-',0,0,'c-','LineWidth',1.5,'EraseMode','xor');
            case 2
                    lines = plot(axes1,handles.SimData(1,:),handles.SimData(plots1(1),:),'b-',handles.SimData(1,:),handles.SimData(plots1(2),:),'r-',0,0,'c-','LineWidth',1.5,'EraseMode','xor');
            case 3
                    lines = plot(axes1,handles.SimData(1,:),handles.SimData(plots1(1),:),'b-',handles.SimData(1,:),handles.SimData(plots1(2),:),'r-',handles.SimData(1,:),handles.SimData(plots1(3),:),'c-','LineWidth',1.5,'EraseMode','xor');
        end

        set(lines,'EraseMode','none');
        
        if axes1 == handles.AxesInput
            handles.inAxLines = lines;
            handles.axlims = [xlims ylims1; handles.axlims(2,:)];
        else
            handles.outAxLines = lines;
            handles.axlims = [handles.axlims(1,:); xlims ylims1];
        end
        
        guidata(fig, handles);
        
        set(axes1,'XLimMode','manual','YLimMode','manual',...
                                'XGrid','on','YGrid','on','GridLineStyle',':',...
                                'XLim',xlims,'Ylim',ylims1);
        ylabel(axes1,ylbl1); xlabel(axes1,xlbl1);
        if ~isempty(plots1)
            legend(axes1,handles.SimDataOrder{plots1},'Location','NorthWest');
        end
        
    elseif nargin == 2
        % When the user chooses different data to plot from the "Setup
        % Plot" menus, this code will run
        
        newPlots = varargin{1};
        axHandle = varargin{2};
        fig = findobj('Tag','CarSim');

        handles = guidata(fig);
        if length(handles.SimData) > 1
            xlims = [handles.SimData(1,1), handles.SimData(1,end)];
            ylims = YAxisLims(handles.SimData(newPlots,:));
        else
            xlims = [0 1];
            ylim = [-1 1];
        end
            if axHandle == handles.AxesInput
                handles.axlims = [xlims ylims; handles.axlims(2,:)];
            else
                handles.axlims = [handles.axlims(1,:); xlims ylims];
            end
        guidata(axHandle,handles);
        set(axHandle,'Xlim',xlims,'YLim',ylims);
        set(get(axHandle,'Children'),'EraseMode','xor');

    elseif nargin == 1
        % Update Plots using plotTrace
        % The TimerFcn Callback executes this code, which then calls the
        % "plotTrace" subfunction below
       try
            pTimer = varargin{1};
            fig = findobj('Tag','CarSim');
            handles = guidata(fig);
            if mod(get(pTimer,'UserData'),5) == 0
                CarSim('ProgressMeter',double(get(pTimer,'Period'))*double(get(pTimer,'UserData'))/handles.SimulationTime, handles);
            end
            % Current Index

            if plotTrace(pTimer,handles.inAxLines,handles.outAxLines,handles.SimData(1,:),handles.SimData(handles.PlotSelection1,:),handles.SimData(handles.PlotSelection2,:));
                 handles.SimulationIsRunning = 0;   
                 stop(pTimer)
                 delete(pTimer)
                 handles.SimulationIsRunning = 0;
                 set(fig,'Resize','on','DoubleBuffer','on');
                 CarSim('ProgressMeter',1, handles);
                 guidata(fig,handles);
                 set(handles.PlaySim, 'string', 'Simulate Response','Value',0);
            end
            % Update the Animation
             dt = find(handles.SimData(1,:) > (get(pTimer,'Period')*get(pTimer,'UserData')),1,'first');
             idx = [find(handles.SimData(1,:) > handles.SimData(1,dt)-3.1,1,'first'):find(handles.SimData(1,:) < handles.SimData(1,dt)+3.1,1,'last')]; 
             SpringDamper(handles.SpringDamper,handles.SimData(2,dt),handles.SimData(3,dt),[(handles.SimData(1,idx)-handles.SimData(1,dt));handles.SimData(2,idx)],handles.ExperimentSelect);
       catch
                 stop(pTimer)
                 delete(pTimer)
                 set(fig,'Resize','on','DoubleBuffer','on');
                 CarSim('ProgressMeter',1, handles);
                 set(handles.PlaySim, 'string', 'Simulate Response','Value',0);
                 handles.SimulationIsRunning = 0;
                 guidata(fig,handles);
       end
end

function lims = YAxisLims(plotData)
    % Calculates Appropriate Y Axes Limits, given some data arrays of the
    % same length

    if isempty(plotData)
        lims = [-1 1];
    else
        for ii = 1:min(size(plotData))
            extrema(ii,:) = [min(plotData(ii,:)) max(plotData(ii,:))];
        end
        lims = [1.1*min(extrema(:,1)) 1.1*max(extrema(:,2))];
    end

 
function done = plotTrace(pTimer, plotLines1, plotLines2, t, dataSet1, dataSet2)
    % Runs every timer period.  Called from the main function. Plots all
    % the data passed to it in dataSet.
    
    count = get(pTimer,'UserData') + 1;
    dt = get(pTimer,'Period');  % stepsize  = period*vectorlength/time
    idx = find(t > count*dt,1,'first');
    if idx < length(t) && all(ishandle(plotLines1)) && all(ishandle(plotLines2))
        for ii = 1:min(size(dataSet1))
                set(plotLines1(ii),'xdata',t(1:idx),'ydata',dataSet1(ii,1:idx),'Erasemode','none');
        end
        if isempty(ii) ii = 0; end
        if ii < length(plotLines1)
            set(plotLines1(ii+1:end),'xdata',[],'ydata',[],'Erasemode','xor');
        end
        for ii = 1:min(size(dataSet2))
                set(plotLines2(ii),'xdata',t(1:idx),'ydata',dataSet2(ii,1:idx),'Erasemode','none');
        end
        if isempty(ii) ii = 0; end
        if ii < length(plotLines2)
            set(plotLines2(ii+1:end),'xdata',[],'ydata',[],'Erasemode','xor');
        end
        set(pTimer,'UserData',count);
        done = 0;
    else
        done = 1;
    end