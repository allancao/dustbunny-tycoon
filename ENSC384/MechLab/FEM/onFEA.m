function onFEA
% callback for click on Finite element Analyze button (should only be called once a model
% has been loaded)

global hMessageBardisplace;
global hMessageBarelement;
global hMainWindow;
global hFigure;
global noderesult;
global elementresult;
global hGraphSelect;
global element;
global node;
global femSolved;
solveFem;
% analyze Finite element model
if(~femSolved)
    return;
end
% direct plot output to figure axes, clear axes, draw the model
for k=1:5
    set(hGraphSelect(k),'Enable','on');
end
onSelect(1);
%show the result in text
resulttext=sprintf('****Nodal Displacement Result******\n');
tmptext=sprintf(' Node       Ux            Uy          Angle of Bending\n');
resulttext = [resulttext,tmptext];
for lop=1:size(node,1);
      iNo=1;
      for lop1=1:lop-1
         iNo=iNo+node(lop1,2);
      end
      if node(lop,2)==2          
         tmptext=sprintf('%5d   %8.3e   %8.3e   %8.3e\n',lop,noderesult(iNo,1),noderesult(iNo+1,1),0.0);
      else
         tmptext=sprintf('%5d   %8.3e   %8.3e   %8.3e\n',lop,noderesult(iNo,1),noderesult(iNo+1,1),noderesult(iNo+2,1));
      end
   resulttext = [resulttext,tmptext];
end
tmptext=sprintf('****Nodal Reaction  Result******\n');
resulttext = [resulttext,tmptext];
tmptext=sprintf(' Node        Fx               Fy             Moment\n');
resulttext = [resulttext,tmptext];
for lop=1:size(node,1);
    iNo=1;
    for lop1=1:lop-1
        iNo=iNo+node(lop1,2);
    end
   if node(lop,2)==2          %
     tmptext=sprintf('%5d   %8.3e   %8.3e   %8.3e\n',lop,noderesult(iNo,2),noderesult(iNo+1,2),0.0);
   else
     tmptext=sprintf('%5d   %8.3e   %8.3e   %8.3e\n',lop,noderesult(iNo,2),noderesult(iNo+1,2),noderesult(iNo+2,2));
   end
   resulttext = [resulttext,tmptext];
end
set(hMessageBardisplace,'String',resulttext);
%element result
resulttext=sprintf('****Element Result******\n');
tmptext=sprintf(' Elem     AXFORCE     SHEARING  BENDMOMENT   AXSTRESS   MAXBENDSTRESS\n');
resulttext = [resulttext,tmptext];
for lop=1:size(element,1);
    tmptext=sprintf('%5d',lop);
    resulttext = [resulttext,tmptext];
    for lop1=1:5
        tmptext=sprintf('    %8.3e',elementresult(lop,lop1));
        resulttext = [resulttext,tmptext];
    end
    tmptext=sprintf('\n');
    resulttext = [resulttext,tmptext];
end
set(hMessageBarelement,'String',resulttext);



