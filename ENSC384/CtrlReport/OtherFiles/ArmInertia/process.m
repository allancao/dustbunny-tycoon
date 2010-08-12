function [ tend, wend, vavg, wfinal ] = process(simout, vfs, vfe)
%PROCESS Summary of this function goes here
%   Detailed explanation goes here

    t1p = find(eq(simout.signals.values(:,3),0), 1,'last');
    t2p = find(gt(simout.signals.values(:,3),max(simout.signals.values(:,3))/1.5), 1);
    
    t1 = simout.signals.values(t1p,1);
    t2 = simout.signals.values(t2p,1);

    tend = t2 - t1;
    wend = simout.signals.values(t2p,3);
    vavg = sum(simout.signals.values(t1p:t2p,2))/length(simout.signals.values(t1p:t2p,2));
    
    plot(simout.signals.values(:,1), simout.signals.values(:,2), simout.signals.values(:,1), simout.signals.values(:,3));
    
    wft1p = find(gt(simout.signals.values(:,1),vfs), 1, 'first');
    wft2p = find(gt(simout.signals.values(:,1),vfe), 1, 'first');
    
    wfinal = sum(simout.signals.values(wft1p:wft2p,3))/length(simout.signals.values(wft1p:wft2p,3));
end

