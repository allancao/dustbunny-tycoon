
global node;     
global element;  
global material; 
global section;  


%%%%node information:No,DOF, coordinate of node_X,Y, constraint
%%%%information_X,Y,Angle(1 is constraint, 0 is free),force on node
%%%%Fx,_Fy,_Moment
node=...
[ 1   2  0.0    0.0   1  1   0    0  0      0
  2   2  0.0    .05   1  1   0    0  0      0
  3   2  .15    .05   0  0   0    0  0      0
  4   2  .30    .05   0  0   0    0  0      0
  5   2  0.30    .0   0  0   0    0  -1      0
  6   2  0.20    .0   0  0   0    0  0      0
  %7   2  0.10    0.0   0  0   0    0  0      0
  
                                            ];
%element information:No,node1,node2,Element Type(1 is Truss,2 is Beam),
%Material No, Cross-Section No
element=...
[   1   2   3       1   1    1
    2   3   1       1   1    1
    3   3   6       1   1    1
    4   3   4       1   1    1
    5   4   6       1   1    1
    6   4   5       1   1    1
    7   5   6       1   1    1
    8   6   1       1   1    1
    %9   7   1       1   1    1      
                                    ];

%Material information:Material No, Modulus of elasticity
material=[ 1   96e9];

%Cross-Section No, Cross-sectional area, Moment of Inertia, the Maximum
%distance from Neutral axis
section=[  1   7.9173e-6  0.0  0.0  ];
save('truss3.mat','node','element','material','section');

length = (30*2 + 5 + sqrt(15^2 + 5^2) + sqrt(10^2 + 5^2) + sqrt(2*5^2))/100

