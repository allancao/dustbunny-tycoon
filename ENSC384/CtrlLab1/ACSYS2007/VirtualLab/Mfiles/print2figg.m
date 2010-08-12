% print2figg
%   This script is called by the "Print To Figure" button.
%   Handles the request based on whether the "Reuse Axes" checkbox is
%   selected.

if ~ishandle(vars.printfig(1)) || ~(get(guiel.plot2samefig,'Value'));
    vars.printfig(1) = figure; set(vars.printfig(1),'Name',[vars.response_type ' Response plot'],'NumberTitle','off');
    vars.printfig(2) = axes('Parent',vars.printfig(1));
    plot(vars.printfig(2),get(guiel.oTrace(1),'XData'),get(guiel.oTrace(1),'YData'),'b-',get(guiel.oTrace(2),'XData'),get(guiel.oTrace(2),'YData'),'r-','LineWidth',1.5);
    set(vars.printfig(2),'Units','Normalized','Position',[0.1 0.1 0.8 0.8],'Xlim',vars.axlims(1:2),'Ylim',vars.axlims(3:4),'GridLineStyle',':','XGrid','on','YGrid','on');
    legend(vars.printfig(2),'Output','Input');
    copyobj(get(guiel.hAX(1),'ylabel'),vars.printfig(2));
    copyobj(get(guiel.hAX(1),'xlabel'),vars.printfig(2))
    copyobj(get(guiel.hAX(1),'title'),vars.printfig(2));
elseif ishandle(vars.printfig(1)) && (get(guiel.plot2samefig,'Value'));
    axes(vars.printfig(2));
    legend(vars.printfig(2),'off');
    currlims = [get(vars.printfig(2),'Xlim') get(vars.printfig(2),'Ylim')];
    currlims = [min(currlims(1),vars.axlims(1)) max(currlims(2),vars.axlims(2)) min(currlims(3),vars.axlims(3)) max(currlims(4),vars.axlims(4))];
    set(vars.printfig(2),'NextPlot','add','XLimMode','manual','YLimMode','manual','XLim',currlims(1:2),'YLim',currlims(3:4));    
    corder = get(vars.printfig(2),'ColorOrder'); corder = [corder(1,:);corder(3,:);corder(2,:);corder(4:end,:)];
    plot(vars.printfig(2),get(guiel.oTrace(1),'XData'),get(guiel.oTrace(1),'YData'),'Color',corder(mod(length(get(vars.printfig(2),'Children'))+1,length(corder))+1,:),'LineWidth',1.5);
    legcom = 'legend(vars.printfig(2),''Output1'',''Input';
    for ii = 2:length(get(vars.printfig(2),'Children'))-1
        legcom = [legcom ''',''Output' num2str(ii) ];
    end
    legcom = [legcom ''');'];
    eval(legcom); clear legcom corder;
    figure(vars.printfig(1));
end