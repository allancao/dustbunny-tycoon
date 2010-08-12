function texTF = poly2tex_2(num,den,varargin)

    % poly2tex_2
    % texTF = poly2tex_2(num,den,lhs);
    %   num - transfer function numerator
    %   den - transfer function denominator
    %   lhs - left hand side of function
    %
    % Returns the transfer function in latex form, for display as a text
    % object on an axes, with the latex interpreter.  Sets the highest
    % order coefficient in the denominator to 1.
    
    

    % Make sure the highest order denominator coefficient is 1

    while den(1) == 0
        den = den(2:end);
    end
    while num(1) == 0
        num = num(2:end);
    end
    
    lhs = char(varargin);
    
    if nargin == 3
        texTF = ['$' lhs '\frac{'];
    else
        texTF = ['$\frac{'];
    end
    if num(1) < 0
       texTF = [texTF '-']; 
    end
    
    for ii = 1:length(num)-1
        if abs(num(ii)) == 1
            texTF = [texTF sprintf('s^{%d}+',length(num)-ii)];
        elseif num(ii) ~= 0
            texTF = [texTF sprintf('%4.3gs^{%d}+',abs(num(ii)),length(num)-ii)];
        end
        if num(ii+1) < 0
            texTF(end) = '-';
        end
    end

    if length(den) ~= 1
        if abs(den(1)) == 1
            if den(1) > 0
                texTF = [texTF sprintf('%4.3g}{s^{%d}+',abs(num(length(num))),length(den)-1)];
            else
                texTF = [texTF sprintf('%4.3g}{-s^{%d}+',abs(num(length(num))),length(den)-1)];
            end
        else 
            texTF = [texTF sprintf('%4.3g}{%4.3gs^{%d}+',abs(num(length(num))),den(1),length(den)-1)];
        end
        if den(2) < 0
            texTF(end) = '-';
        end
        for ii = 2:length(den)-1
            if abs(den(ii)) == 1
                texTF = [texTF sprintf('s^{%d}+',length(den)-ii)];
            elseif den(ii) ~= 0
                texTF = [texTF sprintf('%4.3gs^{%d}+',abs(den(ii)),length(den)-ii)];
            end
            if den(ii+1) < 0
                texTF(end) = '-';
            end
        end
            texTF = [texTF sprintf('%4.3g}$',abs(den(length(den))))];
    else
        texTF = [texTF sprintf('%4.3g}{%4.3g}$',abs(num(length(num))),den(1))];
    end
    
    texTF = cleanExps(texTF);

    
%======================================================================    
%This section gets rid of the 1 exponent and a zero in the S^0 spot.

    for kk=1:length(texTF)-3
        if isequal(texTF(kk:kk+3),'^{1}');
        texTF(kk:kk+3)='    ';
        end
    end
    
    for kk=1:length(texTF)-4
        if isequal(texTF(kk:kk+4),'+   0');
           texTF(kk:kk+4)='     ';
        end
    end
%======================================================================



    
%-----------------------------------------------------------------       
%       Start of cleanExps
%-----------------------------------------------------------------  
function instring = cleanExps(instring)
        exps = findstr(instring,'e+');
        maxn = length(exps);
        if ~isempty(exps)
            for ii = 1:maxn
                if isempty(exps) break; end
                instring = strrep(instring,instring(exps(1):exps(1)+4),['\cdot 10^{' num2str(str2num(instring(exps(1)+2:exps(1)+4))) '}']);
                exps = findstr(instring,'e+');
            end
        end

        exps = findstr(instring,'e-');
        maxn = length(exps);
        if ~isempty(exps)
            for ii = 1:maxn
                if isempty(exps) break; end
                instring =strrep(instring,instring(exps(1):exps(1)+4),['\cdot 10^{-' num2str(str2num(instring(exps(1)+2:exps(1)+4))) '}']);
                exps = findstr(instring,'e-');
            end
        end
%-----------------------------------------------------------------       
%       End of cleanExps
%-----------------------------------------------------------------  