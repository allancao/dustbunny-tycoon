%----------------------------------
% PREPARE POLAR PLOT
%----------------------------------
        vars.angle=0:0.01:2*pi;
        x1=5*cos(vars.angle);
        y1=5*sin(vars.angle);
        x2=10*cos(vars.angle);
        y2=10*sin(vars.angle);
        x3=15*cos(vars.angle);
        y3=15*sin(vars.angle);
        x4=20*cos(vars.angle);
        y4=20*sin(vars.angle);
        x5=25*cos(vars.angle);
        y5=25*sin(vars.angle);

        
        patch('Parent',guiel.hAX(2),'XData',x4,'YData',y4,'FaceColor',[1 1 1]);
  
        set(guiel.hAX(2),'Nextplot','add');          

        plot(guiel.hAX(2),x1,y1,'r:',x2,y2,'r:',x3,y3,'r:',x4,y4,'k-');
        



        vars.angle = [0 1/6 2/6 3/6 4/6 5/6 6/6]*pi;

   % Trace six lines through the circular plot
        plot(guiel.hAX(2),20*[cos(vars.angle(1)),cos(-vars.angle(7))],20*[sin(vars.angle(1)),sin(-vars.angle(7))],'r:');
        plot(guiel.hAX(2),20*[cos(vars.angle(2)),cos(-vars.angle(6))],20*[sin(vars.angle(2)),sin(-vars.angle(6))],'r:');
        plot(guiel.hAX(2),20*[cos(vars.angle(3)),cos(-vars.angle(5))],20*[sin(vars.angle(3)),sin(-vars.angle(5))],'r:');
        plot(guiel.hAX(2),20*[cos(vars.angle(4)),cos(-vars.angle(4))],20*[sin(vars.angle(4)),sin(-vars.angle(4))],'r:');
        plot(guiel.hAX(2),20*[cos(vars.angle(5)),cos(-vars.angle(3))],20*[sin(vars.angle(5)),sin(-vars.angle(3))],'r:');
        plot(guiel.hAX(2),20*[cos(vars.angle(6)),cos(-vars.angle(2))],20*[sin(vars.angle(6)),sin(-vars.angle(2))],'r:');

        %Prime the lines
        guiel.hPolar(1) = plot(guiel.hAX(2),[0,20*cosd(0)],[0,20*sind(0)],'m--','LineWidth',2);
        guiel.hPolar(2) = plot(guiel.hAX(2),[0,20*cos(0)],[0,20*sin(0)],'b-','LineWidth',2);
        
        set(guiel.hAX(2),'XLimMode','manual','YLimMode','manual','DataAspectRatio',[1 1 1],...
            'DataAspectRatioMode','manual','GridLineStyle','none','Xlim',[-25 25],'YLim',[-25 25],...
            'PlotBoxAspectRatioMode','manual','Visible','off','NextPlot','replace');
        
        % Labels
   
        for ii = 0:30:330
            text(22.5*cosd(ii),22.5*sind(ii),num2str(ii),'Fontsize',9,'VerticalAlignment','middle','HorizontalAlignment','center','Parent',guiel.hAX(2))
        end
        
        clear x1 x2 x3 x4 x5 y1 y2 y3 y4 y5;