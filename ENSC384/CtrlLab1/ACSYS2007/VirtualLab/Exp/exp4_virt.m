% function exp4
% exp4  -	A MATLAB based application used to examine the frequency_virt response of DC motors.
% This application makes extensive use of the GUI capabilities
% of Matlab R12. 
%
% © Farid Golnaraghi 1993, 1999, 2002, 2007
% The MechWorks Software Inc., Waterloo, Ont., Canada
% Version 2007
%=============================================================
% Author: Johannes Minor
% Virtual Lab, Experiment 4: Open Loop Sine Input GUI
% Last Modified: July 10, 2007
%=============================================================

vars.response_type = 'Frequency';
vars.simfilename = 'frequency_virt';

vars.simtime = 5;


%===================================================================
% Create panel for application
%===================================================================

    set(guiel.APPWINDOW,'Name','Virtual Lab: Experiment 4: Open Loop Sine Input © 2007 Farid Golnaraghi');
    exp_fig;
    
    guiel.helptext = {...
        'Virtual Lab - Experiment 4: Open Loop Sine Input',...
        '',...
        'Click "Enter Model Parameters" to open the Simulink block diagram.',...
        'Double click on the "Sine Wave" block to modify system input.',...
        '',...
        'To run the simulation, close the Simulink Block Diagram and click "Run Simulation".',...
        'To export the time response plot as it currently appears, click "Plot To Figure".  If you wish to plot multiple response curves on the same figure, check the "Reuse Axes" checkbox.',...
        '',...
        'Enter in the frequency (rad/s) of the input Sine Wave into the field labeled "Enter frequency(rad/s):".  Click on "Calculate" to find the gain and phase of the response.',...
        '',...
        'Click the Zoom button and drag an area on the plot to set new axes limits.',...
        'Click the Cursor button and use the mouse to find exact point values on the plot, or skip through data values with the arrow keys.'};