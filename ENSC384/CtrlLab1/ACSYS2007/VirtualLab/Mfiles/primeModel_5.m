% primeModel_5
% Prepares the axis hAX(2) and the appropriate vectors and constants
% for the puck drop experiment animation


% if isvalid(vars.pTimer) 
%     stop(vars.pTimer); 
%     delete(vars.pTimer); 
% end
set(guiel.APPWINDOW,'Resize','off','KeyPressFcn','');
set(guiel.hAX(1),'ButtonDownFcn','');
vars.pTimerPeriod = round(1000/15)/1000;
vars.pTimer = timer('Period',vars.pTimerPeriod,'BusyMode','drop','TimerFcn',...
    'modelTrace_5(anim, rd, hght, guiel.hAX(2), guiel.oTrace, vars.pTimer, guiel.APPWINDOW);','UserData',1,...
    'ErrorFcn','stop(gcbo); delete(gcbo); set(113,''Resize'',''on'');',...
    'ExecutionMode','fixedDelay');



[anim, rd, hght, guiel.hAX(2)] = drawModel(guiel.hAX(2),[vars.armradius vars.dropheight],get(guiel.hAX(2),'Position'));
progmeter(0.01,'open');
% Acquire Data from Simulink Model
anim.t = output.time;                            % Output Time
anim.ip = input.signals.values;
anim.dropAngle = anim.ip(end);
anim.pos = output.signals.values;                % Arm position - degrees
anim.mgnt = magnet.signals.values;               % 1 - held ; 0 - dropped
anim.vel = velocity.signals.values;              % degrees/second
anim.dropt = 0;
anim.dt = ceil(numel(anim.t)*vars.pTimerPeriod/vars.simtime);
anim.puckpos = zeros(3,numel(anim.t));

progmeter(0.02);
%------------------------------------------
%  PLOTTRACE
%------------------------------------------
set(guiel.zoomzoom,'Enable','on'); set(guiel.zazoomzoomzoom,'Enable','off');

set(guiel.hAX(1),'NextPlot','replace');

guiel.oTrace = plot(guiel.hAX(1),anim.t(1),anim.pos(1),'b-',anim.t(1),anim.ip(1),'r-',...
    0,0,'s','EraseMode','none','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',3,...
    'LineWidth',1.5);

vars.axlims = [0 vars.simtime 1.05*[ min(anim.pos(find(anim.pos == min(anim.pos),1,'first')),...
    anim.ip(find(anim.ip == min(anim.ip),1,'first'))),...
    1.05*max(anim.pos(find(anim.pos == max(anim.pos),1,'first')),...
    anim.ip(find(anim.ip == max(anim.ip),1,'first')))]];

progmeter(0.03);

set(guiel.hAX(1),'XLim',vars.axlims(1:2),...
    'YLim',vars.axlims(3:4),...
    'GridLineStyle',':','XMinorGrid','off','YMinorGrid','off','XGrid','on','YGrid','on',...
    'title',text('Parent',guiel.hAX(1),'String',[vars.response_type ' Response']),'xlabel',text('Parent',guiel.hAX(1),'String','Time (sec)'),'ylabel',text('Parent',guiel.hAX(1),'String',vars.plot_units));
legend(guiel.hAX(1),'Output','Input');



%------------------------------------------
%  END OF PLOTTRACE
%------------------------------------------

%------------------------------------------
%  Calculate Puck Position
%------------------------------------------
anim.puckontable = 0;
anim.puckinhole = 0;
anim.landtime = -1;
for ii = 1:length(anim.t)
   if mod(ii,20) == 0
       progmeter(ii/length(anim.t));
   end
    
    if anim.mgnt(ii) < 0.9 || anim.dropt ~= 0
        %  Magnet has been dropped
        if anim.dropt == 0
            anim.dropt = anim.t(ii);
            anim.throwSpeed = (sum(anim.pos(ii:ii+19))/20-sum(anim.pos(ii-20:ii-1))/20)/(anim.t(ii+10)-anim.t(ii-10));
            anim.throwSpeed = anim.throwSpeed*rd.arm*pi/180;
            anim.releaseDirection = abs(anim.throwSpeed)*[cosd(anim.pos(ii) + sign(anim.throwSpeed)*90),...
                                                sind(anim.pos(ii) + sign(anim.throwSpeed)*90)];
            
        end
            anim.puckpos(1,ii) = anim.puckpos(1,ii-1) + anim.releaseDirection(1)*(anim.t(ii)-anim.t(ii-1));      % Calculate x,y position
            anim.puckpos(2,ii) = anim.puckpos(2,ii-1) + anim.releaseDirection(2)*(anim.t(ii)-anim.t(ii-1));  
            if anim.puckpos(3,ii-1) > hght.base+hght.puck
                anim.puckpos(3,ii) = (-9810/2)*(anim.t(ii)-anim.dropt)^2 + hght.mag;   % Calculate Height
            else
                anim.puckpos(3,ii) = hght.base+hght.puck + 0.01;                              % Puck has landed
                if sqrt(anim.puckpos(1,ii)^2 + anim.puckpos(2,ii)^2) <= rd.base   % Puck is still on the base
                   anim.puckontable = 1;
                   anim.landtime = anim.t(ii);
                   tmp.holex = rd.arm*cosd(anim.ip(ii));
                   tmp.holey = rd.arm*sind(anim.ip(ii));
                   if ((tmp.holex-anim.puckpos(1,ii))^2 + (tmp.holey-anim.puckpos(2,ii))^2)^0.5 < rd.hole-rd.puck/2
                       anim.puckinhole = 1;
                       anim.puckpos(1,ii+1:end) = tmp.holex;
                       anim.puckpos(2,ii+1:end) = tmp.holey;
                       anim.puckpos(3,ii+1:end) = hght.base+hght.puck*.25;
                   else
                        anim.puckpos(1,ii+1:end) = anim.puckpos(1,ii);
                        anim.puckpos(2,ii+1:end) = anim.puckpos(2,ii);
                        anim.puckpos(3,ii+1:end) = anim.puckpos(3,ii);
                   end
                   break
                end
                anim.puckpos(3,ii) = (-9810/2)*(anim.t(ii)-anim.dropt)^2 + hght.mag;
            end
    else
        anim.puckpos(1,ii) = rd.arm*cosd(anim.pos(ii));
        anim.puckpos(2,ii) = rd.arm*sind(anim.pos(ii));
        anim.puckpos(3,ii) = hght.mag;
    end
end


clear ii;
progmeter(0.9,'close');

figure(guiel.APPWINDOW);
start(vars.pTimer);