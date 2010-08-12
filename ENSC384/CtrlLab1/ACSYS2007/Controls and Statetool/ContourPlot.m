try

vabls.ContourPoles=[];
axes(guiele.ResponsePlotAxis);

hold on;


if vabls.pdllChooser==1  %PD tool is being used
    
    vabls.kValues=logspace(log10(str2num(get(guiele.pdMinEdit,'string'))),log10(str2num(get(guiele.pdMaxEdit,'string'))),str2num(get(guiele.pdStepsEdit,'string')));
    vabls.Row3Temp=vabls.Row3*[1 1];
    vabls.Row4Temp=vabls.Row4;          %this is given a different value when Lead Lag is done
    
    
elseif vabls.pdllChooser==2  %LL tool is being used
    
    vabls.kValues=logspace(log10(str2num(get(guiele.MinEditLL,'string'))),log10(str2num(get(guiele.MaxEditLL,'string'))),str2num(get(guiele.StepsEditLL,'string')));    %these are the values of T for each run
    vabls.Row3Start=vabls.Row3*[str2num(get(guiele.aEditLL,'string')) 1];   %this stays constant through the for loop, it is used to make each new vabls.Row3Temp
    vabls.Row3Temp=vabls.Row3Start;
    vabls.Row4Temp=vabls.Row4*[1 1];
    
end

for kk=vabls.kValues;
    
   
    if vabls.pdllChooser==1  %pd tool is being used
    
        vabls.Row3Temp(1)=vabls.Row3*kk;     %This is the value of Kd varying from small to big
    
    elseif vabls.pdllChooser==2  %LL tool is being used
        
        vabls.Row3Temp(1)=vabls.Row3Start(1)*kk;       %these two make T vary from small to big
        vabls.Row4Temp(1)=vabls.Row4*kk;
              
    end
        
        
        
    vabls.Term1=conv(vabls.Row2,conv(vabls.Row4Temp,vabls.Row6));       %make the denominator of the CLTF for one value of kd or T
    vabls.Term2=conv(vabls.Row1,conv(vabls.Row3Temp,vabls.Row5));
    
    
    if  length(vabls.Term1) > length(vabls.Term2)       %this if and the elseif give the two polynomials the same legnth so the vectors can be added
        vabls.zeromatrix=zeros(length(vabls.Term1)-length(vabls.Term2));
        vabls.Term2=[vabls.zeromatrix(1,:),vabls.Term2];                   
    
    elseif  length(vabls.Term1) < length(vabls.Term2)
        vabls.zeromatrix=zeros(length(vabls.Term2)-length(vabls.Term1));
        vabls.Term1=[vabls.zeromatrix(1,:),vabls.Term1];
    end
  
    
    vabls.ClosedLoopDen=vabls.Term1+vabls.Term2;
    
    vabls.ContourPoles=[vabls.ContourPoles roots(vabls.ClosedLoopDen)]; 
 
end
     %this is called ResponsePlotLine because of some functionality it
     %shares with the Response Plot. 
     %the poles and zeros of the uncompensated system are plotted before
     %this script is called.
    guiele.ResponsePlotLine=plot(guiele.ResponsePlotAxis,real(vabls.ContourPoles)',imag(vabls.ContourPoles)','linestyle','none','color',[1 0 0],'marker','.','markersize',5);  
    %the X and Y data are transposed because the above plot command runs
    %once for every column. This would be a problem mainly with the zoom box
    %and cursor fcns because the redraw is slow.
    
    plot(guiele.ResponsePlotAxis,get(guiele.ResponsePlotAxis,'xlim'),[0 0],'linestyle',':','color',[0 0 0]);
    
vabls.ResponseXdata=[min(real(vabls.ContourPoles)) max(real(vabls.ContourPoles))];  %this is used by cnstn.Zoomout.
vabls.PoleZeroAxisLimitsX=get(guiele.ResponsePlotAxis,'xlim');

if vabls.PoleZeroAxisLimitsX(2)<0   %make sure the plot shows the zero point on the real axis.
    vabls.PoleZeroAxisLimitsX(2)=0;
    set(guiele.ResponsePlotAxis,'xlim',vabls.PoleZeroAxisLimitsX);
end


hold off;
    
        
catch
    guiele.pdErrorFig=errordlg('Warning: Bad Value Entered');
    set(guiele.pdErrorFig,'windowstyle','modal');
end
