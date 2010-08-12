% enter_callback.m
% This file is called by the button called PolyEnterButton which is created in 
% the Controls file. This file turns the vector entered by the user in the 
% transfer function edit boxes into a string that can be displayed. As
% well, it assigns the coeficient vector to the proper Row variable. 
% 
% Version (2007.4.2) Michael Ages
% Last Modified 06/12/2007
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

switch  1           %The first case is run only if it is F that has been edited. In which case just these few lines are all that are needed.
    case vabls.button_chooser==7
        
        vabls.Row7=str2num(get(guiele.EditF,'string'));
      
        set(guiele.text_f,'string',['$',num2str(vabls.Row7),'$']);
        set(guiele.InputLabelF,'visible','off');
        set(guiele.EditF,'visible','off');
        set(guiele.InstructionsF,'visible','off');
        set(guiele.PolyEnterInstructions,'visible','on');
                
     case vabls.button_chooser~=7   %This means that either G, C or H was pressed.

% This switch statement decides which button to display the string on
% and hides the enter button and the textbox. vabls.Row1-7 are also used by
% many of the calculations done elswhere in the program.
    switch 1
        case vabls.button_chooser==1
            vabls.Row1=str2num(get(guiele.PolystringEditNum,'string'));
            vabls.Row2=str2num(get(guiele.PolystringEditDen,'string'));
            set(guiele.text_g,'string',poly2tex(vabls.Row1,vabls.Row2,'G(s)='));
            set(guiele.InputLabelG,'visible','off');
        case vabls.button_chooser==3
            vabls.Row3=str2num(get(guiele.PolystringEditNum,'string'));
            vabls.Row4=str2num(get(guiele.PolystringEditDen,'string'));
            set(guiele.text_c,'string',poly2tex(vabls.Row3,vabls.Row4,'C(s)='));
            set(guiele.InputLabelC,'visible','off');
        case vabls.button_chooser==5
            vabls.Row5=str2num(get(guiele.PolystringEditNum,'string'));
            vabls.Row6=str2num(get(guiele.PolystringEditDen,'string'));
            set(guiele.text_h,'string',poly2tex(vabls.Row5,vabls.Row6,'H(s)='));
            set(guiele.InputLabelH,'visible','off');
    end

end   %This 'end' is associated with the switch at the top of the file.
