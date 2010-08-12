function onSelect(n)
% callback for the radio button group.
global hGraphSelect graphSelect;
global femSolved;

for k=1:5
    if(k==n)
        set(hGraphSelect(k),'Value',1);
        graphSelect=k;
    else
        set(hGraphSelect(k),'Value',0);
    end;
end;
if(femSolved)
    showModel;
end 