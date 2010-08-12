function drawConstraint(coords,dir,type)
% draw force;
global node;
SIZE=max(max(node(:,3)),max(node(:,4)))/40;
if(type==1)%x,y
    thetha=atan2(dir(2,:),dir(1,:));
    % prepare arrowhead points
    points1(1,:)=[0 -SIZE -SIZE];
    points1(2,:)=[0 SIZE/3 -SIZE/3];
  
     % rotate
    tt=[cos(-thetha) sin(-thetha); -sin(-thetha) cos(-thetha)];
    points=tt*points1;
    % translate 
    points=[points(1,:)+coords(1,1) ; points(2,:)+coords(1,2)];
    % draw symbol;
    fill(points(1,:), points(2,:),'k','LineWidth',1);
end 
%darw moment
if(type==2)
    NROUNDPOINTS=20;
    rad=SIZE/2;
    % prepare points
    d=linspace(0,2*pi,NROUNDPOINTS);
    points=rad*[cos(d);sin(d)];
    % translate 
   points=[points(1,:)+coords(1,1); points(2,:)+coords(1,2)];
   % draw symbol;
    fill(points(1,:), points(2,:),'r','LineWidth',2);
end


