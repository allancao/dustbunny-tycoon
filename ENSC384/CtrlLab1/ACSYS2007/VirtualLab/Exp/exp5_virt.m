% function exp5
% exp5  -	A MATLAB based application that is a simulated control design project.
% This application makes extensive use of the GUI capabilities
% of Matlab R12.
% To run, select Experiment #5 from the Experiment Menu in SIMLab
%
% © Farid Golnaraghi 1993, 1999, 2002, 2007
% The MechWorks Software Inc., Waterloo, Ont., Canada
% Version 2007
%=============================================================
% Author: Johannes Minor
% Virtual Lab, Experiment 5: Control System Design GUI
% Last Modified: July 10, 2007
%=============================================================


vars.response_type = 'Position';
vars.simfilename = 'controldesign_virt';

vars.simtime = 3;

%===================================================================
% Create figure for application
%===================================================================

    set(guiel.APPWINDOW,'Name','Virtual Lab: Experiment 5: Control System Design © 2007 Farid Golnaraghi');

    exp_fig;

    guiel.helptext = {...
        'Virtual Lab - Experiment 5: Control System Design - Puck Drop Experiment',...
        '',...
        'Click "Enter Model Parameters" to open the Simulink block diagram.',...
        'Double click on the "PID" block to modify controller parameters.',...
        'Double click on the "Input Step" block to modify system input.',...
        'Double click on the "Electromagnet Control" to set the release angle and position trigger enable time. ',...
        '',...
        'To run the simulation, close the Simulink Block Diagram and click "Run Simulation". "Stop Simulation" halts the animation.',...
        'To export the time response plot as it currently appears, click "Plot To Figure".  If you wish to plot multiple response curves on the same figure, check the "Reuse Axes" checkbox.',...
        '',...
        'Click the Zoom button and drag an area on the plot to set new axes limits.',...
        'Click the Cursor button and use the mouse to find exact point values on the plot, or skip through data values with the arrow keys.'};