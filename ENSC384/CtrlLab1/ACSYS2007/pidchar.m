function [ risetime, overshoot ] = pidchar( input, output )
%PIDCHAR Summary of this function goes here
%   Detailed explanation goes here

    risetime = output.time(find(output.signals.values > input*0.9, 1)) - output.time(find(output.signals.values > input*0.1, 1))
    overshoot = (max(output.signals.values ) - input)/input
    
end

