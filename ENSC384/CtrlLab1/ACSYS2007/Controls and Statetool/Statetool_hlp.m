Introd=sprintf(' Statetool() - This application makes extensive use of the GUI capabilities \n of Matlab R12. This function is used for analysis of systems in State-Space \n form. To run the application, just type "Acsys" in MATLAB Command window and \n choose the State Space option from the pop-up menu. After this point all \n operations are done with custom GUI controls.');
Enter=sprintf(' Enter A,B,C,D matrices in the text boxes. \n You may also use the ACSYS program: Transfer Function Symbolic \n for some State-Space applications.');
Cal=sprintf(' Use this menu to calculate the A matrix eigenvalues and eigenvectors and \n other state space calculations. The Controlability and Observability options \n and the Time Response options may only be activated after the State Space \n Calculation is completed.');
Timresp=sprintf(' The time response of the system. Includes: \n\n The Natural Response (i.e. response due to initial conditions only), \n\n Step Response and the Impulse Response,  \n\n Any other inputs (must be a function of time) \n e.g. sin(2*t) or exp(5*t) \n\n Note that the time response may only be calculated after the state space \n calculations have run.');
Accessories=sprintf(' Help: \n This menu option takes the user to the Controls help menu. Within the menu, \n the user can obtain an online description of this toolbox and its supporting functions. \n\n Unit conversion is a tool for the conversion of units.');
Reset=sprintf(' Application of this button will reset the Controls window. \n The user must re-enter all parmeters to continue.');
Done=sprintf(' Application of this button will Close the Controls window. It is reccomended \n that the user press this button before using another Acsys tool');

str={'Introduction', Introd;
   'Input Module', Enter;
   'Calculate/Display', Cal;
   'Time Response', Timresp;
   'Accessories', Accessories;
   'Reset', Reset;
   'Close Window', Done;};
helpwin(str,'Introduction','ACSYS Help on State Space Tool')

