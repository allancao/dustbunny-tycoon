% function exp2
% exp2  -	A MATLAB based application used to examine the position control of DC motors.
% This application makes extensive use of the GUI capabilities
% of Matlab R12. 
% To run, select Experiment #2 from the Experiment Menu in Virtual Lab
%
% © Farid Golnaraghi 1993, 1999, 2002, 2007
% The MechWorks Software Inc., Waterloo, Ont., Canada
% Version 2007
%=============================================================
% Author: Johannes Minor
% Virtual Lab, Experiment 2: Position control GUI
% Last Modified: July 10, 2007
%=============================================================

vars.response_type = 'Position';
vars.simfilename = 'positionctrl_virt';

vars.simtime = 3;


%===================================================================
% Create Panel for application
%===================================================================
    set(guiel.APPWINDOW,'Name','Virtual Lab: Experiment 2: Position Control © 2007 Farid Golnaraghi');
    exp_fig;
    
    guiel.helptext = {...
        'Virtual Lab - Experiment 2: Position Control',...
        '',...
        'Click "Enter Model Parameters" to open the Simulink block diagram.',...
        'Double click on the "PID" block to modify controller parameters.',...
        'Double click on the "Step Input" block  to modify system input.',...
        '',...
        'To run the simulation, close the Simulink Block Diagram and click "Run Simulation". "Stop Simulation" halts the animation.',...
        'To export the time response plot as it currently appears, click "Plot To Figure".',...
        '',...
        'Click the Zoom button and drag an area on the plot to set new axes limits.',...
        'Click the Cursor button and use the mouse to find exact point values on the plot, or skip through data values with the arrow keys.'};