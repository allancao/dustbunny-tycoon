function newval=convtool(typeval,old,new,oldval)


convtype = ['convertarea    ';
	    'convertmoment  ';
	    'convertdensity ';
	    'convertforce   ';
	    'convertlength  ';
	    'convertmass    ';
	    'convertpressure';
	    'convertstress  ';
	    'converttorque  ';
	    'convertwork    '];


convertarea  = [6.451600000;
   		0.006944444;
		1.000000000;
		0.000645160];

convertmoment = [41.62314273;
		 0.000048225;
		 1.000000000;
		 0.000000416];

convertdensity = [27679.90000;
		  27.67990000;
		  1728.000000;
		  1.000000000];

convertforce = [0.001000000;
		0.004448222;
		1.000000000;
      4.448222000;
      1e-3];

convertlength = [2.540000000;
		 0.083333333;
		 1.000000000;
		 0.000025400;
       0.025400000
       1.5783e-5];

convertmass =  [453.5924000;
		0.453592400;
		1.000000000;
		0.031080143;
		0.000453600];

convertpressure = [1.000000000;
    1.013250000;
   1.01325e6;
		   101.3250000;
		   14.69600000;
		   760.0000000;
         0.103250000;
		   101325.0000];

convertstress = [1.000000000;
      1.013250000;
      1.01325e6;
		 101.3250000;
		 14.69600000;
		 760.0000000;
		 0.103250000;
		 101325.0000];

converttorque = [1054.350000;
		 1.000000000;
		 777.6491000;
       1.054350000;
       1.076e7;
		 0.000392800;
		 0.252000000;
		 0.000292900;
		 0.292875000;
		 1054.350000];

convertwork =  [1054.350000;
		1.000000000;
		777.6491000;
      1.054350000;
      1.076e7;
		0.000392800;
		0.252000000;
		0.000292900; 
		0.292875000;
		1054.350000];
		 
typename = convtype(typeval,:);
typemat = eval(str2mat(typename));
%oldnum = str2num(oldval);
newval = str2num(oldval)*typemat(new)/typemat(old);



 
