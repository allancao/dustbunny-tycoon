function showModel
%show the model in windows
global hSlider;
global hMainWindow;
global hLegend;
global hFigure;
global node;
global element;
global femSolved;
global u;
global graphSelect; 
global elementresult;
cla;
hold on;
%%%%%%Draw Node

if(max(node(:,3))==min(node(:,3))||max(node(:,4))==min(node(:,4)))
    set(hMainWindow,'CurrentAxes',hFigure);
    axis equal; % figure axis is always 1:1
end
numberofnodes=size(node,1);
for lop=1:numberofnodes

    infoText=['N' num2str(lop,'%4d')];
    text(node(lop,3),node(lop,4),infoText,'Color','b');
end
numberofelements=size(element,1);
for lop=1:numberofelements
    %draw element
    pointx=[node(element(lop,2),3),node(element(lop,3),3)];
    pointy=[node(element(lop,2),4),node(element(lop,3),4)];
    %draw element
    if(element(lop,4)==1)%truss
        LW=2;
    else
        LW=4;
    end
    line(pointx,pointy,'Color','k','LineWidth',LW);
    infoText=['E' num2str(lop,'%4d')];
    text((pointx(1,1)+pointx(1,2))/2.0,(pointy(1,1)+pointy(1,2))/2.0,infoText,'Color','r');
end
    scale=get(hSlider,'Value');
%%%%%%%%%%%%%Draw Disform
if(femSolved)

    for lop=1:numberofelements
        %draw element
        i=element(lop,2);
        j=element(lop,3);
        % nodal displacement
        iNo=1;
        jNo=1;
        for lop1=1:i-1
            iNo=iNo+node(lop1,2);
        end
        for lop1=1:j-1
            jNo=jNo+node(lop1,2);
        end
        pointx=[node(element(lop,2),3)+u(iNo,1)*scale,node(element(lop,3),3)+u(jNo,1)*scale];
        pointy=[node(element(lop,2),4)+u(iNo+1,1)*scale,node(element(lop,3),4)+u(jNo+1,1)*scale];
        %draw element
        if(element(lop,4)==1)%truss
            LW=2;
        else
            LW=4;
        end
        %definite color of the element
        elementItem=elementresult(:,graphSelect);
        maxValue=max(elementItem);
        minValue=min(elementItem);
        if(maxValue~=minValue)
            spanValue=(maxValue-minValue)/5;
            colorTable=['b' 'g' 'y' 'm' 'r'];
            for lop1=1:5
                if(elementItem(lop)<=minValue+spanValue*lop1+1)&&(elementItem(lop)>=minValue+spanValue*(lop1-1)-1)
                    elementColor=colorTable(lop1);
                end
            end
        else
            elementColor='r';
        end
        line(pointx,pointy,'Color',elementColor,'LineWidth',LW);
        infoText=['E' num2str(lop,'%4d')];
        text((pointx(1,1)+pointx(1,2))/2.0,(pointy(1,1)+pointy(1,2))/2.0,infoText,'Color','b');
    end
end
%%%%%%%%%%%%%%%Draw force
for lop=1:numberofnodes
    if(node(lop,8)~=0)%FX
        force=[node(lop,8) 0]';
        point(1,:)=[node(lop,3) node(lop,4)];
        drawForce(point,force,1);
    end
    if(node(lop,9)~=0)%Fy
        force=[0 node(lop,9)]';
        point(1,:)=[node(lop,3) node(lop,4)];
        drawForce(point,force,1);
    end
    if(node(lop,10)~=0)%M
        force=[node(lop,10) 0]';
        point(1,:)=[node(lop,3) node(lop,4)];
        drawForce(point,force,2);
    end
end
%%%%%%%%%%%%%%%Draw constraint
for lop=1:numberofnodes
    if(node(lop,5)~=0)%SX
        dir=[1 0]';
        point(1,:)=[node(lop,3) node(lop,4)];
        drawConstraint(point,dir,1);
    end
    if(node(lop,6)~=0)%SY
        dir=[0 1]';
        point(1,:)=[node(lop,3) node(lop,4)];
        drawConstraint(point,dir,1);
    end
    if(node(lop,7)~=0)%SM
        dir=[1 1]';
        point(1,:)=[node(lop,3) node(lop,4)];
        drawConstraint(point,dir,2);  
    end
end
%%%%%%%%%%%%%Draw Disform
if(femSolved)
    set(hMainWindow,'CurrentAxes',hLegend);
    cla;
    hold on;
    plot(rand(2,1),'Color','b','Visible','off');
    plot(rand(3,1),'Color','g','Visible','off');
    plot(rand(4,1),'Color','y','Visible','off');
    plot(rand(5,1),'Color','m','Visible','off');
    plot(rand(6,1),'Color','r','Visible','off');
    %%%%%%%%%%%%%%%%Draw legend
    set(hLegend,'Visible','off');
    str1=sprintf('%8.2e\nTo%8.2e',minValue,(maxValue-minValue)*0.2+minValue);
    str2=sprintf('%8.2e\nTo%8.2e',(maxValue-minValue)*0.2+minValue,(maxValue-minValue)*0.4+minValue);
    str3=sprintf('%8.2e\nTo%8.2e',(maxValue-minValue)*0.4+minValue,(maxValue-minValue)*0.6+minValue);
    str4=sprintf('%8.2e\nTo%8.2e',(maxValue-minValue)*0.6+minValue,(maxValue-minValue)*0.8+minValue);
    str5=sprintf('%8.2e\nTo%8.2e',(maxValue-minValue)*0.8+minValue,maxValue);
    h=legend(str1,str2,str3,str4,str5,5);
    set(h,'Interpreter','none');
    set(hMainWindow,'CurrentAxes',hFigure);
end
