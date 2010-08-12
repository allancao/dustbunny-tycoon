Mwksglbl
cMARGIN = .1;
cBOX1_W = .3;
cBOX1_H = .2;
matrix=[' '];

%************************************************************************
%The following section initializes and produces all of the popup menus.
%Each matrix describes each dimension and units.

dimen=['Area                  ';
	'Area_Moment_of_Inertia';
	'Density               ';
	'Force                 ';
	'Length                ';
	'Mass                  ';
	'Pressure              ';
	'Stress                ';
	'Torque                ';
	'Work                  '];

Area = ['cm^2';
	'ft^2';
	'in^2';
	'm^2 '];

Area_Moment_of_Inertia =['cm^4';
			 'ft^4';
			 'in^4';
			 'm^4 '];

Density = ['kg/m^3  ';
	   'g/cm^3  ';
	   'lbm/ft^3';
	   'lbm/in^3'];

Force =  ['dyn  '; 
	  'kip  ';
	  'KN   ';
	  'lbf  ';
	  'N    '];

Length = ['cm   ';
       	  'ft   ';
     	  'in   ';
	  'km   ';
    	  'm    ';
  	  'miles';];	

Mass = ['g   ';
	'kg  ';
	'lbm ';
	'slug';
	'ton '];

Pressure = ['atm      ';
 	    'bar      ';
	    'dyne/cm^2';
	    'Kpa      ';
	    'lbf/in^2 ';
 	    'mm Hg    ';
	    'MPa      ';
	    'Pa       '];
	         			
Stress = ['atm      ';
 	  'bar      ';
	  'dyne/cm^2';
	  'Kpa      ';
	  'lbf/in^2 ';
 	  'mm Hg    ';
	  'MPa      ';
	  'Pa       '];

Torque = ['J     ';
	  'Btu   ';
	  'ft*lbf';
	  'KJ    ';
	  'g*cm  ';
          'hp*h  ';
	  'kg*cal';
	  'KW*h  ';
	  'W*h   ';
	  'W*s   ']; 
	  

Work=['J     ';
	'Btu   ';
	'ft*lbf';
	'KJ    ';
	'g*cm  ';
   'hp*h  ';
	'kg*cal';
	'KW*h  ';
	'W*h   ';
	'W*s   ']; 
	  
%********************************************************************

%figure('Name','Unit Conversion Tool')
CONVWIND=figure('Units','Normal','Position',[0.3 0.3 .4 .3],...
	'color',LIGHTGREY,'Name','Unit Conversion Tool ©1997-2002 Farid Golnaraghi',...
	'NumberTitle','off','WindowStyle','Modal','Resize','Off');
      
uicontrol(CONVWIND,'Units','Normal','Style','Text',...
   'Position',[ 1/10  5/9 1.5/10 1/9],'Foreground',TITLFORE,'Background',LIGHTGREY,...
   'Horizontal','Left','Fontsize',10,'FontWeight','Bold','String','From:');        

oldvalue = uicontrol(CONVWIND,'Units','Normal','Style','Edit',...
	'Position',[2.5/10 5/9 4.0/10 1/9]);

oldunit = uicontrol(CONVWIND,'Units','Normal','Style','Popup',...
   'Position',[  7/10 5/9 2.0/10 1/9],'String',Area,...
	'CallBack','unitfrom=matrix(get(oldunit,''Value''),:);');

uicontrol(CONVWIND,'Units','Normal','Style','Text',...
   'Position',[1/10  3/9 1.5/10 1/9],'Foreground',TITLFORE,'Background',LIGHTGREY,...
   'Horizontal','Left','Fontsize',10,'FontWeight','Bold','String','To:');        

newvalue = uicontrol(CONVWIND,'Units','Normal','Style','Text',...
	'Position',[2.5/10 3/9 4.0/10 1/9],'string',' - ');

newunit = uicontrol(CONVWIND,'Units','Normal','Style','Popup',...
   'Position',[ 7/10  3/9 2.0/10 1/9],'String',Area,...
	'CallBack','unitto=matrix(get(newunit,''Value''),:);');

typeval=1;

uicontrol(CONVWIND,'Units','Normal','Style','Text',...
   'Position',[  1/10 7/9 3.5/10 1/9],'Foreground',TITLFORE,'Background',LIGHTGREY,...
   'Horizontal','Left','Fontsize',10,'FontWeight','Bold','String','Quantity Type:');        

type=uicontrol(CONVWIND,'Units','Normal','Style','Popup',...
   'Position',[4.0/10 7/9 5.0/10 1/9],'String', dimen,'Fontsize',10,'FontWeight','Bold',...
   'CallBack',[...
		'typeval = get(type,''Value'');',...
		'matname=dimen(typeval,:);',...
		'matrix=eval(str2mat(matname));',...
		'default=matrix(1,:);',...
		'set(oldunit,''String'',matrix);',...
		'set(newunit,''String'',matrix);']);	

convert = uicontrol(CONVWIND,...
		'Style', 'push',...
		'String','CONVERT',...
        'Fontsize',10,'FontWeight','Bold',...
		'Units','normal', 'Position',[1/10 1/9 4/10 1/9],...
		'CallBack',[...
		'old = get(oldunit,''Value'');',...
		'new = get(newunit,''Value'');',...
		'oldval = get(oldvalue,''String'');',...		
		'newval = convtool(typeval,old,new,oldval);',...
		'set(newvalue,''String'',num2str(newval));']);

 uicontrol(CONVWIND,...
		'Style','push',...
		'String','CLOSE',...
        'Fontsize',10,'FontWeight','Bold',...
		'Units','normal', 'Position',[5/10 1/9 4/10 1/9],...
		'CallBack','eval(''close(CONVWIND)'')');
   
