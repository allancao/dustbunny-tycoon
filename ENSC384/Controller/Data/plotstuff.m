function plotstuff( simout, column, tstart,tend)%, simout2, column2, shift)
%PLOTSTUFF Summary of this function goes here
%   Detailed explanation goes here

    buffer = 1.05;

    tistart = find(gt(simout.signals.values(:,1),tstart), 1);
    tiend = find(gt(simout.signals.values(:,1),tend), 1);

    %tistart2 = find(gt(simout2.signals.values(:,1),tstart + shift), 1);
    %tiend2 = find(gt(simout2.signals.values(:,1),tend + shift), 1);
    
    %plot(simout.signals.values(tistart:tiend,1), simout.signals.values(tistart:tiend,column), simout2.signals.values(tistart:tiend,1), simout2.signals.values(tistart2:tiend2,column2));
    plot(simout.signals.values(tistart:tiend,1), simout.signals.values(tistart:tiend,column));
    
    minval = min(min(simout.signals.values(tistart:tiend,column)));
    maxval = max(max(simout.signals.values(tistart:tiend,column)));

    axis([tstart,tend, minval*buffer, maxval*buffer]);
end

