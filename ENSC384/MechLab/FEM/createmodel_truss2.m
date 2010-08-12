
global node;     
global element;  
global material; 
global section;  


%%%%node information:No,DOF, coordinate of node_X,Y, constraint
%%%%information_X,Y,Angle(1 is constraint, 0 is free),force on node
%%%%Fx,_Fy,_Moment
node=...
[ 1    2  0.0      0.0   1  1   0    0  0      0
  2    2  0.05      0.0   0  0   0    0  0      0
  3    2  0.10     0.0   0  0   0    0  0      0
  4    2  0.15     0.0   0  0   0    0  0      0
  5    2  0.20     0.0   0  0   0    0  0      0
  6    2  0.25     0.0   0  0   0    0  0      0
  7    2  0.30     0.0   0  0   0    0  -5     0
  8    2  0.30     0.05   0  0   0    0  0      0
  9    2  0.25     0.05   0  0   0    0  0      0
  10   2  0.20     0.05   0  0   0    0  0      0
  11   2  0.15     0.05   0  0   0    0  0      0
  12   2  0.10     0.05   0  0   0    0  0      0
  13   2  0.05     0.05   0  0   0    0  0      0
  14   2  0.0      0.05   1  1   0    0  0      0];

%element information:No,node1,node2,Element Type(1 is Truss,2 is Beam),
%Material No, Cross-Section No
element=...
[   1    1   2       1   1    1
    2    2   3       1   1    1
    3    3   4       1   1    1
    4    4   5       1   1    1
    5    5   6       1   1    1
    6    6   7       1   1    1
    7    8   9       1   1    1
    8    9   10      1   1    1
    9    10  11      1   1    1
    10   11  12      1   1    1
    11   12  13      1   1    1
    12   13  14      1   1    1
    13   14  1       1   1    1
    14   1   13      1   1    1
    15   13  2       1   1    1
    16   2   12      1   1    1
    17   12  3       1   1    1
    18   3   11      1   1    1
    12   11  4       1   1    1
    13   4   10      1   1    1
    14   10  5       1   1    1
    15   5   9       1   1    1
    16   9   6       1   1    1
    17   6   8       1   1    1
    18   8   7       1   1    1];

%Material information:Material No, Modulus of elasticity
material=[ 1   96e9];

%Cross-Section No, Cross-sectional area, Moment of Inertia, the Maximum
%distance from Neutral axis
section=[  1   7.917e-6  0.0  0.0  ];
save('truss3.mat','node','element','material','section');
