function result=loadFile(modelFileName)
clear node element material section;
clear elementresult;
load(modelFileName);          % Check whether the model data is correct
if(exist('node') && exist('element')&& exist('material') && exist('section'))
    global node
    global element
    global material
    global section
    result=true;                    %right
else 
    result=false;                   %wrong
    return;
end
%judge the available of the model
for lop=1:size(element,1);
    if(element(lop,4)~=1&&element(lop,4)~=2)
        str=sprintf('The Type of Element %d is wrong\n It must be 1 or 2',lop);
        MsgBox(str,'Error','error','modal');
        result=false;
        return;
    end
    if size(section,1)<element(lop,6)
        str=sprintf('The Section Paramete No of Element %d is wrong',lop);
        MsgBox(str,'Error','error','modal');
        result=false;
        return;
    end
     if size(material,1)<element(lop,5)
        str=sprintf('The Material Paramete No of Element %d is wrong',lop);
        MsgBox(str,'Error','error','modal');
        result=false;
        return;
    end
end
