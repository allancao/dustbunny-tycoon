% PRIMEPLOT
% - primePlot
%       Prepares the Axes hAX(1) for the animated XY Time Response plot
%
set(guiel.zoomzoom,'Enable','on'); set(guiel.zazoomzoomzoom,'Enable','off');
vars.enableanimation = 0;
if isvalid(vars.pTimer) 
    stop(vars.pTimer); 
    delete(vars.pTimer); 
end
set(guiel.APPWINDOW,'Resize','off');
anim.cursor = 1;
vars.pTimerPeriod = round(1000/15)/1000;
vars.pTimer = timer('Period',vars.pTimerPeriod,'BusyMode','drop','TimerFcn',...
    'plotTrace(vars.pTimer,guiel.oTrace,anim.dt,anim.t,anim.pos,anim.ip,guiel.APPWINDOW);','UserData',1,...
    'ErrorFcn','stop(gcbo); delete(gcbo); set(113,''Resize'',''on'');',...
    'ExecutionMode','fixedDelay');
anim.pos = output.signals.values;
anim.ip = input.signals.values;
anim.t = output.time;
anim.dt = ceil(numel(anim.t)*vars.pTimerPeriod/vars.simtime);
set(guiel.hAX(1),'NextPlot','replace');
guiel.oTrace = plot(guiel.hAX(1),anim.t(1),anim.pos(1),'b-',anim.t(1),anim.ip(1),'r-',0,0,'k','EraseMode','none','LineWidth',1.5);
legend(guiel.hAX(1),'Output','Input');

vars.axlims = [0 vars.simtime,...
    1.05*[ min(anim.pos(find(anim.pos == min(anim.pos),1,'first')),anim.ip(find(anim.ip == min(anim.ip),1,'first'))),...
    1.05*max(anim.pos(find(anim.pos == max(anim.pos),1,'first')),anim.ip(find(anim.ip == max(anim.ip),1,'first')))]];

set(guiel.hAX(1),'XLim',vars.axlims(1:2),...
    'YLim',vars.axlims(3:4),'XGrid','on','Ygrid','on',...
    'GridLineStyle',':','xlabel',text('String','Time (sec)'),'ylabel',text('String',vars.plot_units));
drawnow
start(vars.pTimer);