function [ pcr ] = buckling( l )
%BUCKLING Summary of this function goes here
%   Detailed explanation goes here

    k = 1.0;
    E = 96e9;
    
    r = 0.003175/2;
    I = pi*r^4/4;

    pcr = pi^2*E*I/(k*l)^2;

end

