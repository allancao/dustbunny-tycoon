% PLOTTRACE
%   - plotTrace(pTimer,oTrace,dt,t,pos,ip)
%             -pTimer - A timer object
%             -oTrace - A plot object handle
%             -dt - Number of data points per timer period
%             -t - Time vector
%             -pos - Output Vector
%             -ip - Input Vector
%             
%     plotTrace updates oTrace every oTimer period

function plotTrace(pTimer,oTrace,dt,t,pos,ip,figg)
    count = int32(get(pTimer,'UserData') + 1);
    if count*dt < length(t) && all(ishandle(oTrace))
        set(oTrace(1),'xdata',t(1:count*dt),'ydata',pos(1:count*dt))
        set(oTrace(2),'xdata',t(1:count*dt),'ydata',ip(1:count*dt))
        set(pTimer,'UserData',count)
        drawnow
    else
        stop(pTimer)
        delete(pTimer)
        set(figg,'Resize','on');
    end