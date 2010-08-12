function solveFem

global numberofnodes;
global numberofelements;
global femSolved;
global node;            %node information:No,DOF, coordinate of node_X,Y, constraint information_X,Y,Angle(1 is constraint, 0 is free),force on node Fx,_Fy,_Moment
global element;         %element information:No,node1,node2,Element Type(1 is Truss,2 is Beam),Material No, Cross-Section No
global material;        %Material information:Material No, Modulus of elasticity
global section;         %Cross-Section No, Cross-sectional area, Moment of Inertia, the Maximum distance from Neutral axis
global elementresult;   %element result: Axial force, Share ,Bending Moment, tension and compression stress,Maximum Bending Stress
global u;               %node result: nodal displacement
global noderesult;      %node result: reaction
numberofnodes = size(node,1);
numberofelements=size(element,1);
%Calculate the DOF of the node
TotalDof=0;
for lop1=1:numberofnodes
    for lop2=1:numberofelements
        node(lop1,2)=2;
        if ((element(lop2,4)==2)&&(element(lop2,2)==node(lop1,1)||element(lop2,3)==node(lop1,1)))
            node(lop1,2)=3;
            break;
        end
    end
     %Calculate the dimension of the stiffness matrix.
     TotalDof=TotalDof+node(lop1,2);
end
%difinite the matrix
kk=zeros([TotalDof,TotalDof]);
kksave=zeros([TotalDof,TotalDof]);
f=zeros([TotalDof,1]);
elementresult=zeros([numberofelements,5]);
for lop=1:numberofelements
   i=element(lop,2);
   j=element(lop,3);
   xi=node(i,3);
   yi=node(i,4);
   xj=node(j,3);
   yj=node(j,4);
   dl=sqrt((xj-xi)^2+(yj-yi)^2);
   s=(yj-yi)/dl;
   c=(xj-xi)/dl;
    if element(lop,4)==1          %truss
        
        ea=material(element(lop,5),2)*section(element(lop,6),2)/dl;
        ek=ea*[c*c, c*s, -c*c,-c*s; s*c, s*s, -c*s,-s*s; -c*c, -c*s, c*c, c*s; -c*s, -s*s, s*c, s*s];
        %assemble the total stiffness matrix
        iNo=1;
        jNo=1;
        for lop1=1:i-1
            iNo=iNo+node(lop1,2);
        end
        for lop1=1:j-1
            jNo=jNo+node(lop1,2);
        end
        kk(iNo:iNo+1,iNo:iNo+1)= kk(iNo:iNo+1,iNo:iNo+1)+ek(1:2,1:2);
        kk(iNo:iNo+1,jNo:jNo+1)= kk(iNo:iNo+1,jNo:jNo+1)+ek(1:2,3:4);
        kk(jNo:jNo+1,iNo:iNo+1)= kk(jNo:jNo+1,iNo:iNo+1)+ek(3:4,1:2);
        kk(jNo:jNo+1,jNo:jNo+1)= kk(jNo:jNo+1,jNo:jNo+1)+ek(3:4,3:4);
    
        
    else                         %beam
        ei=material(element(lop,5),2)*section(element(lop,6),3);
        ea=material(element(lop,5),2)*section(element(lop,6),2);
        ekk=[ea/dl      0            0         -ea/dl     0             0
                 0   12*ei/dl^3    6*ei/dl^2    0        -12*ei/dl^3   6*ei/dl^2
                 0   6*ei/dl^2     4*ei/dl      0        -6*ei/dl^2    2*ei/dl
            -ea/dl      0            0          ea/dl     0             0
                0   -12*ei/dl^3    -6*ei/dl^2   0         12*ei/dl^3  -6*ei/dl^2
                0   6*ei/dl^2     2*ei/dl       0         -6*ei/dl^2   4*ei/dl];
        tt=[c   -s 0 0  0 0
            s  c 0 0  0 0
            0   0 1 0  0 0
            0   0 0 c  -s 0
            0   0 0 s c 0
            0   0 0 0  0 1];
        ek=tt*ekk*inv(tt);
 
        %assemble the total stiffness matrix
        iNo=1;
        jNo=1;
        for lop1=1:i-1
            iNo=iNo+node(lop1,2);
        end
        for lop1=1:j-1
            jNo=jNo+node(lop1,2);
        end
        kk(iNo:iNo+2,iNo:iNo+2)= kk(iNo:iNo+2,iNo:iNo+2)+ek(1:3,1:3);
        kk(iNo:iNo+2,jNo:jNo+2)= kk(iNo:iNo+2,jNo:jNo+2)+ek(1:3,4:6);
        kk(jNo:jNo+2,iNo:iNo+2)= kk(jNo:jNo+2,iNo:iNo+2)+ek(4:6,1:3);
        kk(jNo:jNo+2,jNo:jNo+2)= kk(jNo:jNo+2,jNo:jNo+2)+ek(4:6,4:6);
    end
end
kksave=kk;
iNo=0;
for lop=1:numberofnodes

    for lop1=1:node(lop,2)
        % Nodal Force    
        f(iNo+lop1,1)=f(iNo+lop1,1)+node(lop,7+lop1);
        % Nodal Constrait  
        if(node(lop,4+lop1)==1)
            kk(iNo+lop1,iNo+lop1)=10000000*kk(iNo+lop1,iNo+lop1);
            if(kk(iNo+lop1,iNo+lop1)<0.0001)
                kk(iNo+lop1,iNo+lop1)=10000000;
            end
        end
    end
    iNo=iNo+node(lop,2);
end
if(det(kk)<1e-10)
    MsgBox('The model is not properly constrained!  please check model!','Error','error','modal');
    femSolved=false;
    return;
end
u = kk\f;
%calculate interforce and element stress
for lop=1:numberofelements
  % element stiffness matrix 
   i=element(lop,2);
   j=element(lop,3);
   xi=node(i,3);
   yi=node(i,4);
   xj=node(j,3);
   yj=node(j,4);
   dl=sqrt((xj-xi)^2+(yj-yi)^2);
   s=(yj-yi)/dl;
   c=(xj-xi)/dl;
   if element(lop,4)==1          %truss
        ea=material(element(lop,5),2)*section(element(lop,6),2)/dl;
        ek=ea*[1 0 -1 0
               0 0  0 0
              -1 0  1 0
               0 0  0 0];
        tt=[c   -s  0  0 
            s  c  0  0 
            0   0  c  -s 
            0   0 s  c];
    
   else
        ei=material(element(lop,5),2)*section(element(lop,6),3);
        ea=material(element(lop,5),2)*section(element(lop,6),2);
        ek=[ea/dl      0            0         -ea/dl   0             0
                 0   12*ei/dl^3    6*ei/dl^2   0        -12*ei/dl^3   6*ei/dl^2
                 0   6*ei/dl^2     4*ei/dl     0        -6*ei/dl^2    2*ei/dl
            -ea/dl      0            0          ea/dl   0             0
                0   -12*ei/dl^3    -6*ei/dl^2   0        12*ei/dl^3  -6*ei/dl^2
                0   6*ei/dl^2     2*ei/dl     0          -6*ei/dl^2   4*ei/dl];
        tt=[c   -s 0 0  0 0
            s  c 0 0  0 0
            0   0 1 0  0 0
            0   0 0 c  -s 0
            0   0 0 s c 0
            0   0 0 0  0 1];

   end
   % nodal displacement
   iNo=1;
   jNo=1;
   for lop1=1:i-1
        iNo=iNo+node(lop1,2);
   end
   for lop1=1:j-1
        jNo=jNo+node(lop1,2);
   end
   if   element(lop,4)==1   %truss
        nodalu=zeros([4,1]);
        nodalu(1:2,1)=u(iNo:iNo+1,1);
        nodalu(3:4,1)=u(jNo:jNo+1,1);
   else
        nodalu=zeros([6,1]);
        nodalu(1:3)=u(iNo:iNo+2);
        nodalu(4:6)=u(jNo:jNo+2);
   end
   %nodal local displacement
   Lu=inv(tt)*nodalu;
   InnerForce=ek*Lu;
   %stress
   if element(lop,4)==1          %truss
      elementresult(lop,1)=InnerForce(3,1);
      elementresult(lop,4)=InnerForce(3,1)/section(element(lop,6),2);
   else
      elementresult(lop,1)=InnerForce(4,1);
      elementresult(lop,2)=InnerForce(5,1);
      elementresult(lop,3)=max(abs(InnerForce(6,1)),abs(InnerForce(3,1)));
      elementresult(lop,4)=InnerForce(4,1)/section(element(lop,6),2);
      elementresult(lop,5)=elementresult(lop,3)*section(element(lop,6),4)/section(element(lop,6),3);
   end
end
%reaction
reaction=kksave*u-f;
noderesult=[u reaction];
femSolved=true;
   


