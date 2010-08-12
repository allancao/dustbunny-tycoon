
global node;     
global element;  
global material; 
global section;  


%%%%node information:No,DOF, coordinate of node_X,Y, constraint
%%%%information_X,Y,Angle(1 is constraint, 0 is free),force on node
%%%%Fx,_Fy,_Moment
node=...
[ 1      2     0.0      0.0     1    1     0      0     0       0
  2      2     0.10     0.0     0    0     0      0     0       0
  3      2     0.30     0.0     0    0     0      0    -1       0
  4      2     0.20     0.10    0    0     0      0     0       0
  5      2     0.0      0.10    1    1     0      0     0       0];

%element information:No,node1,node2,Element Type(1 is Truss,2 is Beam),
%Material No, Cross-Section No
element=...
[   1   1   2       1   1    1
    2   2   3       1   1    1
    3   2   4       1   1    1
    4   2   5       1   1    1
    5   5   4       1   1    1
    6   3   4       1   1    1];

%Material information:Material No, Modulus of elasticity
material=[ 1   96e9];

%Cross-Section No, Cross-sectional area, Moment of Inertia, the Maximum
%distance from Neutral axis
section=[  1   7.91730436e-6  0.0  0.0  ];
save('truss3.mat','node','element','material','section');
