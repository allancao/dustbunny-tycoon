function varargout = SpringDamper(varargin)
if nargin==6 & nargout==1 % Initialize Spring
    SD.P1 = varargin{1}; % Origin of Spring/Damper Illustration
    SD.Li = varargin{2}; % Initial length of S/D
    SD.Lf = varargin{3}; % final/maximum compressed length
    SD.w = varargin{4}; % width of illustration
    axHandle = varargin{5}; % Animation Axes
    configuration = varargin{6}; % Either 'passive' or 'active'
    
    delete(get(axHandle,'Children'));
    
    SD.SpringDensity = 16; % Defines the # of coils in the spring
    SD.SpringPoints = BuildSpring(SD.P1, SD.Li, SD, SD.SpringDensity);
    SD.DamperPoints = BuildDamper(SD.P1, SD.Li, SD);

    SD.WheelPoints = BuildWheel(SD.P1, SD.w, SD);
    switch configuration
        case 'active'    
            SD.MassPoints = BuildMass(SD.P1, SD.Li, SD.w, SD,1);
            SD.RackPoints = BuildRack(SD.P1, SD.Li, SD.w, SD);
            SD.MotorPoints = BuildMotor(SD.P1, SD.Li, SD.w, SD);
        case 'passive'
            SD.MassPoints = BuildMass(SD.P1, SD.Li, SD.w, SD,0);
            SD.RackPoints = [0 0];
            SD.MotorPoints = [0 0];
    end
    erasemode = 'background';
    
    handles.Origin = SD.P1;
    handles.Length = SD.Li;
  
    set(axHandle,'NextPlot','add');
	handles.Yoffset = SD.P1(2) - min(SD.WheelPoints(:,2)); % shift drw up, since previously the bottom of spring and damper were (P1x, P1y)
	handles.Wheel = line(SD.WheelPoints(:,1), SD.WheelPoints(:,2)+handles.Yoffset, 'color', [0 0 0], 'erasemode', erasemode,'Parent',axHandle);
	handles.Spring = line(SD.SpringPoints(:,1), SD.SpringPoints(:,2)+handles.Yoffset, 'color', [0 0 0], 'erasemode', erasemode,'Parent',axHandle);
	handles.Damper = line(SD.DamperPoints(:,1), SD.DamperPoints(:,2)+handles.Yoffset, 'color', [0 0 0], 'erasemode', erasemode,'Parent',axHandle);
	handles.Mass = line(SD.MassPoints(:,1), SD.MassPoints(:,2)+handles.Yoffset, 'color', [0 0 0], 'erasemode', erasemode,'Parent',axHandle);
	handles.Rack = line(SD.RackPoints(:,1), SD.RackPoints(:,2)+handles.Yoffset, 'color', [0 0 0], 'erasemode', erasemode,'Parent',axHandle);
	handles.Motor = line(SD.MotorPoints(:,1), SD.MotorPoints(:,2)+handles.Yoffset, 'color', [0 0 0], 'erasemode', erasemode,'Parent',axHandle);
    handles.Ground = line(0,0,'color', [0 0 0], 'erasemode', erasemode,'Parent',axHandle);
    
    Ymin = -0.6;
    Ymax = 3;
    handles.YAxisOffset = min(SD.WheelPoints(:,2))+handles.Yoffset - Ymin;
    handles.YAxisRange = Ymax-Ymin;
	set(axHandle, 'ylim', [Ymin Ymax]);
    set(axHandle, 'xlim', [-3 3]);
	handles.xlim = get(axHandle, 'xlim');
    handles.ylim = get(axHandle, 'ylim');
    set(axHandle, 'ylimmode', 'manual', 'xlimmode', 'manual', 'zlimmode', 'manual','DataAspectRatio',[1 1 1]);
	SD.handles = handles;
    % Stores animation data in Line 'UserData' field.
	set(handles.Spring, 'userdata', SD);
	
	%   set(handles.Spring, 'erasemode', 'background')
	%   set(handles.Damper, 'erasemode', 'background')
	
	if nargout ~= 0
	varargout{1} = handles.Spring;
	end
	
else 
        handles.Spring = varargin{1};
        SD = get(handles.Spring,'userdata');
        handles = SD.handles;

        P1 = [SD.P1(1), varargin{2}];
        L = varargin{3}+1;
        GRND = varargin{4};
        configuration = varargin{5};
        

        dy = P1(2) - SD.P1(2); % ie. base absolute movement
        dx = dy + L-SD.Li; % ie. mass absolute movement


        SD.SpringPoints = BuildSpring(P1, L, SD, SD.SpringDensity);
        SD.DamperPoints = BuildDamper(P1, L, SD);
        SD.WheelPoints(:,2) = SD.WheelPoints(:,2) + dy + handles.Yoffset; %SD.WheelPoints = BuildWheel(P1, SD.w, SD);
        switch configuration
            case 'active'    
                SD.MassPoints(:,2) = SD.MassPoints(:,2) + dx + handles.Yoffset; %SD.MassPoints = BuildMass(P1, L, SD.w, SD);
                SD.RackPoints(:,2) = SD.RackPoints(:,2) + dx + handles.Yoffset; %SD.RackPoints = BuildRack(P1, L, SD.w, SD);
                SD.MotorPoints = BuildMotor(P1, L, SD.w, SD);
            case 'passive'
                SD.MassPoints(:,2) = SD.MassPoints(:,2) + dx + handles.Yoffset;
                SD.RackPoints = [0 0];
                SD.MotorPoints = [0 0];
        end
        Ymin = min(SD.WheelPoints(:,2))+handles.Yoffset;
        Ymax = Ymin + handles.YAxisRange;
        WheelZeroOffset = min(SD.WheelPoints(:,2));
        set(get(handles.Motor, 'parent'), 'ylim', handles.ylim+WheelZeroOffset, 'xlim', handles.xlim);
        
        set(handles.Spring, 'xdata', SD.SpringPoints(:,1), 'ydata', SD.SpringPoints(:,2)+handles.Yoffset)
        set(handles.Damper, 'xdata', SD.DamperPoints(:,1), 'ydata', SD.DamperPoints(:,2)+handles.Yoffset)
        set(handles.Mass, 'xdata', SD.MassPoints(:,1), 'ydata', SD.MassPoints(:,2))
        set(handles.Wheel, 'xdata', SD.WheelPoints(:,1), 'ydata', SD.WheelPoints(:,2))
        set(handles.Rack, 'xdata', SD.RackPoints(:,1), 'ydata', SD.RackPoints(:,2))
        set(handles.Motor, 'xdata', SD.MotorPoints(:,1), 'ydata', SD.MotorPoints(:,2)+handles.Yoffset)
        set(handles.Ground,'xdata',GRND(1,:),'Ydata',GRND(2,:));

        drawnow
        %end
end

function DamperPoints = BuildDamper(P1, L, SD)
    Stroke = SD.Li-SD.Lf;
    DamperPoints(1,:) = [P1(1)-SD.w*3/16, P1(2)];
    DamperPoints(2,:) = [P1(1)-SD.w*3/16, P1(2)+SD.Lf/2];
    DamperPoints(3,:) = [DamperPoints(2,1)+SD.w/8, DamperPoints(2,2)];
    DamperPoints(4,:) = [DamperPoints(3,1), DamperPoints(3,2)+Stroke];
    DamperPoints(5,:) = [DamperPoints(4,1), DamperPoints(4,2)-Stroke/2-(SD.Li-L)];
    DamperPoints(6,:) = [DamperPoints(2,1), DamperPoints(5,2)];
    DamperPoints(7,:) = [DamperPoints(6,1), P1(2)+L];
    DamperPoints(8,:) = DamperPoints(6,:);
    DamperPoints(9,:) = [DamperPoints(2,1)-SD.w/8, DamperPoints(5,2)];
    DamperPoints(10,:) = [DamperPoints(9,1), P1(2)+SD.Lf/2+Stroke];
    DamperPoints(11,:) = [DamperPoints(10,1), DamperPoints(10,2)-Stroke];
    DamperPoints(12,:) = DamperPoints(2,:);
    
   
    

function SpringPoints = BuildSpring(P1, L, SD, SpringDensity)
    SpringPoints(1,:) = [P1(1)+SD.w*3/16, P1(2)];
    SpringPoints(2,:) = [P1(1)+SD.w*3/16, P1(2)+SD.Lf/2];
    
    dy = (L-SD.Lf)/SpringDensity;
    
    SecondLastPos = -1;
    LastPos = 0;
    
    x(1:SpringDensity) = P1(1)+SD.w*3/16;
    
    for i = 1:SpringDensity      
        y(i) = P1(2)+SD.Lf/2+i*dy;
        if LastPos == 0 & SecondLastPos == -1 % This point to the right of center
            LastPos = 1;
            SecondLastPos = 0;
            x(i) = x(i) + SD.w/8;
        elseif LastPos == 0 & SecondLastPos == 1 % This point to the left of center
            LastPos = -1;
            SecondLastPos = 0;
            x(i) = x(i) - SD.w/8;
        else
            SecondLastPos = LastPos; % This point in the center
            LastPos = 0;
        end
    end
    
      SpringPoints = [SpringPoints; [x', y']];
      SpringPoints(end+1,:) = [SpringPoints(end,1), SpringPoints(end,2)+SD.Lf/2];

function MassPoints = BuildMass(P1, L, w, SD,flag)
    y1 = P1(2) + 1.25*L; % bottom y of box
    y2 = y1 + w;
    x1 = P1(1)- (w/2); % left x of box
    x2 = P1(1)-w*3/16;
    x3 = P1(1)+w*3/16;
    if flag
        x4 = P1(1)+ (w); % right x of box
    else
        x4 = P1(1)+ (w)/2;
    end
    
    MassPoints(1,:) = [x1, y1];
    MassPoints(2,:) = [x2, y1];
    MassPoints(3,:) = [x2, y1-.25*L];
    MassPoints(4,:) = [x2, y1];
    MassPoints(5,:) = [x3, y1];
    MassPoints(6,:) = [x3, y1-.25*L];
    MassPoints(7,:) = [x3, y1];
    MassPoints(8,:) = [x4, y1];
    MassPoints(9,:) = [x4, y2];
    MassPoints(10,:) = [x1, y2];
    MassPoints(11,:) = [x1, y1];
    
function WheelPoints = BuildWheel(P1, w, SD)
    x1 = P1(1)+w*3/16;
    x2 = P1(1)-w*3/16;
    xc = P1(1);
    y1 = P1(2);
    y2 = y1-w/1.5;
    r = w*.6; % radius
    yc = y2-r;
    
    
    WheelPoints = [x1, y1; x2, y1; xc, y1; xc, y2];
    for w = 0:pi/16:2*pi
        x = r * cos(w+pi/2);
        y = r * sin(w+pi/2);
        WheelPoints(end+1, :) = [x + xc, y + yc];
    end    
    
    for w = 0:pi/16:2*pi
        x = r/2 * cos(w+pi/2);
        y = r/2 * sin(w+pi/2);
        WheelPoints(end+1, :) = [x + xc, y + yc];
    end    
    
%     %         length = xc-x1
%     %   (x1,y1)         (xc,y1)    
%     %           \-----|
%     %            \    |
%     %             \   | length = y1-yc
%     %   length = r \  |
%     %               \ |
%     %                \|
%     %                 | (xc, yc)
%     %
%     % (y1-yc)^2 + (xc-x1)^2 = r^2
%     
%     
%     yc = y1 - sqrt(r^2 - (xc-x1)^2);
%     WheelPoints = [];
%     for w = 0:0.01:2*pi
%         x = r * cos(w);
%         y = r * sin(w);
%         WheelPoints(end+1, :) = [x + xc, y + yc];
%     end
    
function RackPoints = BuildRack(P1, L, w, SD)
    x1 = P1(1)+w*0.8;
    x2 = x1+w*0.15;
    y1 = P1(2) + 1.25*L;
    y2 = y1- 2*w;
    RackPoints = [x1, y1;...
                  x1, y2;...
                  x2, y2;...
                  x2, y1];
          
function MotorPoints = BuildMotor(P1, L, w, SD)
    r = .1;
    xc = P1(1)+w*.8-r;
    yc = P1(2)+L/2;
    MotorPoints = [xc yc];
    Linitial = 1; % see handles.AnimationLength in CarSim.m
    theta0 = (L-Linitial)/r;
    theta1 = theta0+2*pi;
    tooth = 1;
    for w = linspace(theta0,theta1,25)
        if tooth
            x = r * cos(w);
            y = r * sin(w);
        else
            x = 0.75 * r * cos(w);
            y = 0.75 * r * sin(w);
        end
        tooth = ~tooth;
        MotorPoints(end+1, :) = [x + xc, y + yc];
    end
    MotorPoints(end+1, :) = [r*cos(theta0)+xc, r*sin(theta0)+yc];
    