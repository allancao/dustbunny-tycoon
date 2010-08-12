function [ stiff, weight, efficiency ] = stiffness( deflection, length )
%STIFFNESS Summary of this function goes here
%   Detailed explanation goes here

    f = 1;
    density = 8.49/(1.0e-6)*0.001; %g / (m^3)
    a = pi*0.0015875^2;
    
    weight = a*length*density;
    
    stiff = f/deflection;
    efficiency = stiff/weight;

end

