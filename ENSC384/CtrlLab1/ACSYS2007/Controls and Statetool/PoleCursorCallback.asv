%this is set as the button down function of CONTWIND when the pole zero
%cursor button is pressed


%         case 28 % left arrow
%         case 29 % right arrow
%         case 30 % up arrow
%         case 31 % down arrow

if isempty(get(guiele.CONTWIND,'currentcharacter'))~=1

    switch double(get(guiele.CONTWIND,'currentcharacter'))  %check which arrow was pressed
        case 28
            vabls.PoleCursorPos=vabls.PoleCursorPos-1;
        case 29
            vabls.PoleCursorPos=vabls.PoleCursorPos+1;
        case 30
            vabls.PoleCursorPos=vabls.PoleCursorPos+25;
        case 31
            vabls.PoleCursorPos=vabls.PoleCursorPos-25;
    end
end

%This stops the cursor from going over or under the number of k values.
if vabls.PoleCursorPos<1
    vabls.PoleCursorPos=1;
elseif vabls.PoleCursorPos>size(vabls.ContourPoles,2)
    vabls.PoleCursorPos=size(vabls.ContourPoles,2);
end

set(guiele.PoleCursorDot,'xdata',real(vabls.ContourPoles(:,vabls.PoleCursorPos)),'ydata',imag(vabls.ContourPoles(:,vabls.PoleCursorPos)));


set(guiele.PoleCursorTxt,'string',strvcat([vabls.ParameterLabel ' ' num2str(vabls.kValues(vabls.PoleCursorPos))]));

set(guiele.PoleListText,'string',{'Current Poles Are:  ' num2str(vabls.ContourPoles(:,vabls.PoleCursorPos))});





