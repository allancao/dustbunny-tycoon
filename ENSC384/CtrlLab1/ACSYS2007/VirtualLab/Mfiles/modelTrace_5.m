% MODELTRACE
%             
%     modelTrace updates the animation every pTimer period

function modelTrace_5(anim, rd, hght, axHandle, oTrace, pTimer, figg)
    persistent popupFlag;
    persistent tag
    
    if isempty(popupFlag) || popupFlag == -1
        popupFlag = anim.puckontable;
    end
    
    anim.count = int32(get(pTimer,'UserData') + 1);
    if anim.count*anim.dt < length(anim.t) && ishandle(axHandle) && all(ishandle(oTrace))

        anim.oC = anim.pos(anim.count*anim.dt);       % Calculate Magnet Position
        anim.x0 = rd.arm*cosd(anim.oC);       
        anim.y0 = rd.arm*sind(anim.oC);       

        anim.xoff = rd.d*cosd(anim.oC-45);       % Arm Bar Corners
        anim.yoff = rd.d*sind(anim.oC-45);

                                    % Define Vertices
        anim.vert = [ -anim.xoff, -anim.yoff, hght.stand;...
                    anim.yoff, -anim.xoff, hght.stand;...
                    anim.x0+anim.xoff, anim.y0+anim.yoff,hght.stand;...
                    anim.x0-anim.yoff, anim.y0+anim.xoff, hght.stand;...
                    -anim.xoff, -anim.yoff, hght.arm;...
                    anim.yoff, -anim.xoff, hght.arm;...
                    anim.x0+anim.xoff, anim.y0+anim.yoff, hght.arm;...
                    anim.x0-anim.yoff, anim.y0+anim.xoff, hght.arm;];
       
        set(anim.swingArm,'Vertices',anim.vert);

        % Hole
        anim.x = rd.hole*anim.xb + rd.arm*cosd(anim.ip(anim.count*anim.dt));
        anim.y = rd.hole*anim.yb + rd.arm*sind(anim.ip(anim.count*anim.dt));
        anim.z = hght.base*ones(length(anim.x),1)';
        set(anim.hole,'XData',anim.x(1,:),'YData',anim.y(1,:),'ZData',anim.z);
        
        % Magnet
        anim.x = rd.mag*anim.xb+anim.x0;
        anim.y = rd.mag*anim.yb+anim.y0;
        anim.z = [hght.mag*ones(length(anim.x),1)' ; hght.stand*ones(length(anim.x),1)'];
        set(anim.mag(1),'XData',anim.x,'YData',anim.y,'ZData',anim.z);
        set(anim.mag(2),'XData',anim.x(1,:),'YData',anim.y(1,:),'ZData',anim.z(1,:));
        set(anim.mag(3),'XData',anim.x(2,:),'YData',anim.y(2,:),'ZData',anim.z(2,:));

        % Puck
        anim.x = rd.puck*anim.xb+anim.puckpos(1,anim.count*anim.dt);
        anim.y = rd.puck*anim.yb+anim.puckpos(2,anim.count*anim.dt);
        anim.z = [(anim.puckpos(3,anim.count*anim.dt)-hght.puck)*ones(length(anim.x),1)' ;...
            anim.puckpos(3,anim.count*anim.dt)*ones(length(anim.x),1)'];
        set(anim.puck(1),'XData',anim.x,'YData',anim.y,'ZData',anim.z);
        set(anim.puck(2),'XData',anim.x(1,:),'YData',anim.y(1,:),'ZData',anim.z(1,:));
        set(anim.puck(3),'XData',anim.x(2,:),'YData',anim.y(2,:),'ZData',anim.z(2,:));
        if ~popupFlag && (anim.puckpos(1,anim.count*anim.dt)^2 + anim.puckpos(2,anim.count*anim.dt)^2)^0.5 > rd.base
           popupFlag = 1;
           CYAN = 0.95*[1 1 1];
           LIGHTGREY = [0.9 0.9 1];
           set(figg,'Units','Pixels'); figpos = get(figg,'Position'); set(figg,'Units','Normalized');
           popupPanel = uipanel('Parent',figg,'Units','pixels','Position',[ (figpos(3)/2)-100 figpos(4)/2 200 100 ],...
               'BackGroundColor',LIGHTGREY,'BorderType','beveledout','ButtonDownFcn','','Visible','on');
           popupTxT = uicontrol('Parent',popupPanel,'Style','text','Units','Normalized','FontSize',6,...
                'Position',[0 0 1 0.8],'BackGroundColor',CYAN,...
                'String','You Lost The Puck',...
                'fontsize',16,'FontWeight','Demi');
           CursorWindowBar = uicontrol('Parent',popupPanel,'Style','text','Units','Normalized','Enable','off',...
                'Position',[0 0.8 1 0.2],'BackGroundColor',LIGHTGREY,'String','Warning',...
                'ButtonDownFcn',['hoverBox(' num2str(figg,'%15.15f') ',' num2str(popupPanel,'%15.15f') ',gcbo);']);
           uicontrol('Parent',popupPanel,'Units','Normalized','Style','PushButton','String','X',...
                'Position',[0.9 0.8 0.09 0.2],'Callback',...
                ['delete('  num2str(popupPanel,'%15.15f') ');']);            
        end
        % Plot
        set(oTrace(1),'xdata',anim.t(1:anim.count*anim.dt),'ydata',anim.pos(1:anim.count*anim.dt))
        set(oTrace(2),'xdata',anim.t(1:anim.count*anim.dt),'ydata',anim.ip(1:anim.count*anim.dt))
        
        if anim.t(anim.count*anim.dt) > anim.dropt && anim.dropt > 0
            idx = find(anim.t == anim.dropt);
            dropstr = strvcat(['Puck Dropped'],['Time: ' num2str(anim.dropt) 's'],['Position: ' num2str(anim.pos(idx)) ' deg']);
            if isempty(tag)
                plotax = get(oTrace(3),'Parent');
                tag = text(anim.dropt,0.6*anim.pos(idx),dropstr,'FontUnits','points','FontSize',11,'Fontweight','demi','ButtonDownFcn','','Parent',plotax);
                lims = get(plotax,'Ylim');
                set(plotax,'nextplot','add');
                plot(plotax,[anim.dropt anim.dropt anim.dropt],[lims(1)-10 anim.pos(idx) lims(2)+10],'m*--','LineWidth',1,'Markersize',9);
                set(plotax,'nextplot','replace');
            end
        end
        if anim.t(anim.count*anim.dt) > anim.landtime && anim.landtime > 0 && anim.puckinhole && popupFlag
           popupFlag = 0;
           CYAN = 0.95*[1 1 1];
           LIGHTGREY = [0.9 0.9 1];
           set(figg,'Units','Pixels'); figpos = get(figg,'Position'); set(figg,'Units','Normalized');
           popupPanel = uipanel('Parent',figg,'Units','pixels','Position',[ (figpos(3)/2)-100 figpos(4)/2 200 100 ],...
               'BackGroundColor',LIGHTGREY,'BorderType','beveledout','ButtonDownFcn','','Visible','on');
           popupTxT = uicontrol('Parent',popupPanel,'Style','text','Units','Normalized','FontSize',6,...
                'Position',[0 0 1 0.8],'BackGroundColor',CYAN,...
                'String','Success!',...
                'fontsize',16,'FontWeight','Demi');
           CursorWindowBar = uicontrol('Parent',popupPanel,'Style','text','Units','Normalized','Enable','off',...
                'Position',[0 0.8 1 0.2],'BackGroundColor',LIGHTGREY,'String','Message',...
                'ButtonDownFcn',['hoverBox(' num2str(figg,'%15.15f') ',' num2str(popupPanel,'%15.15f') ',gcbo);']);
           uicontrol('Parent',popupPanel,'Units','Normalized','Style','PushButton','String','X',...
                'Position',[0.9 0.8 0.09 0.2],'Callback',...
                ['delete('  num2str(popupPanel,'%15.15f') ');']);    
        end
        set(pTimer,'UserData',anim.count)
        drawnow
    else
        popupFlag = -1;
        clear tag
        set(axHandle,'Nextplot','replace');
        clear anim hght rd;
        stop(pTimer)
        delete(pTimer)
        set(figg,'Resize','on');
    end