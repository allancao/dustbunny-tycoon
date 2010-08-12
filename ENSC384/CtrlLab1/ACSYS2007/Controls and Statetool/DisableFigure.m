function	[oldpropvalues,varargout]=DisableFigure(handlearray,prop,propvalue,varargin);

oldpropvalues=get(handlearray,prop);

%this IF is used to highlight the "modal" panel when anywhere outside it is
%pressed
if length(varargin)==2  
    
    varargout{1}=get(varargin{1},'windowbuttondownfcn');    %these two are the old windowbutton functions which will be put back when the window is put back to normal.
    varargout{2}=get(varargin{1},'windowbuttonupfcn');
    set(varargin{1},'windowbuttondownfcn',['set(' num2str(varargin{2},17) ',''bordertype'',''line'',''borderwidth'',2,''highlightcolor'',[0 0 0])']);
    set(varargin{1},'windowbuttonupfcn',['set(' num2str(varargin{2},17) ',''bordertype'',''beveledout'',''borderwidth'',1,''highlightcolor'',[1 1 1])']);
    
    end 
    
set(handlearray,prop,propvalue);