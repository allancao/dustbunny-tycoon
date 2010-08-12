function drawForce(coords,force,type)
% draw force;
global node;
FORCELINELENGTH=max(max(node(:,3)),max(node(:,4)))/10;
ARROWSIZE=FORCELINELENGTH*0.2;

if(type==1)%force
    thetha=atan2(force(2,:),force(1,:));
    magnitude=norm(force);

    % prepare arrowhead points
    points1(1,:)=[0 -ARROWSIZE -ARROWSIZE];
    points1(2,:)=[0 ARROWSIZE/3 -ARROWSIZE/3];
    tail1=[0 -FORCELINELENGTH ; 0 0];
    info1=[-FORCELINELENGTH; 0 ];

    % rotate
    tt=[cos(-thetha) sin(-thetha); -sin(-thetha) cos(-thetha)];
    points=tt*points1;
    tail=tt*tail1;
    info=tt*info1;

    % translate 
    points=[points(1,:)+coords(1,1) ; points(2,:)+coords(1,2)];
    tail=[tail(1,:)+coords(1,1); tail(2,:)+coords(1,2)];
    info=[info(1,:)+coords(1,1); info(2,:)+coords(1,2)];

    % draw symbol;
    fill(points(1,:), points(2,:),'k','LineWidth',1);
    line(tail(1,:), tail(2,:),'Color','k','LineWidth',1);
    infoText=[num2str(magnitude,'%4.2e')];
    text(info(1,1),info(2,1),infoText);
end 
%darw moment
if(type==2)
    NROUNDPOINTS=20;
    magnitude=abs(force(1,1));
    direction=sign(force(1,1));
    rad=ARROWSIZE*2.5;

    % prepare arrowhead points
    if(direction==1) 
        d=linspace(pi,-pi/2,NROUNDPOINTS*3/4);
        tailpoints=rad*[cos(d);sin(d)];
        arrowpoints(2,:)=[-ARROWSIZE 0 0];
        arrowpoints(1,:)=[-rad -rad+ARROWSIZE/3 -rad-ARROWSIZE/3];
    else 
        d=linspace(pi/2,2*pi,NROUNDPOINTS*3/4);
        tailpoints=rad*[cos(d);sin(d)];
        arrowpoints(1,:)=[ARROWSIZE 0 0];
        arrowpoints(2,:)=[rad rad+ARROWSIZE/3 rad-ARROWSIZE/3];
    end;

    info=[rad/2; direction*rad];

    % translate 
    arrowpoints=[arrowpoints(1,:)+coords(1,1) ; arrowpoints(2,:)+coords(1,2)];
    tailpoints=[tailpoints(1,:)+coords(1,1); tailpoints(2,:)+coords(1,2)];
    info=[info(1,:)+coords(1,1); info(2,:)+coords(1,2)];

    % draw symbol;
    fill(arrowpoints(1,:), arrowpoints(2,:),'k','LineWidth',1);
    line(tailpoints(1,:), tailpoints(2,:),'Color','k','LineWidth',1);
    infoText=[num2str(magnitude,'%4.2e')];
    text(info(1,1),info(2,1),infoText);
end