function tfout = parseTF2(numer,denom,symvars)
    
    % Inverse Laplace Transform with symbolic toolbox.
    % Displays all output to command window.
    % Also does partial fraction expansion for TFs without multiple complex
    % poles, using six digit precision.  That can be changed here:
    numprecision = 6;
    % numer, denom - numerator and denominator strings
    % symvars - string containing any symbolic variables.

    disp('----------------------------------------------------------------')
    disp('           Inverse Laplace Transform')
    disp('----------------------------------------------------------------')
    
    tfflag = 1;
    % Check to see if it is a symbolic expression
    while ~isempty(symvars)
        [symvar symvars] = strtok(symvars,' ,');
        if any(symvar(1) == ['a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z',...
                             'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z'])
            if ~isempty(strfind(numer,symvar)) || ~isempty(strfind(denom,symvar))
                eval(['syms ' symvar ';']);
                tfflag = 0;
            end
        else
            disp(['Warning: ' symvar ' is not a valid symbolic variable.  It must start with a letter (a-z,A-Z).']);
        end
    end

    if tfflag
        % If there are no symbolic variables...
        % Just in case...
        s = tf('s');

        try
            % Numerator
            if any(numer == 's');
                % If numerator was typed in as a function of s
                % ie.  (s^2 + 3*s + 5) was entered
                eval(['num = ' numer ';']);
            else
                % If the numerator was entered as a vector of coefficients
                % ie. [1 3 5]
                num = tf(str2num(numer),[1]);
            end
        catch
           % Catches any errors
           disp(['Numerator ''' strtrim(numer) ''' is invalid.']);
           num = tf([1],[1]);
        end

        % Denominator
        try
            if any(denom == 's');
                eval(['den = ' denom ';']);
                den = 1/den;
            else
                den = tf([1],str2num(denom));
            end
        catch
           disp(['Denominator ''' strtrim(denom) ''' is invalid.']);
           den = tf([1],[1]);
        end

        % Transfer function
        G = num*den;
        disp('G(s) =')
        pretty(poly2sym(G.num{1},'s')/poly2sym(G.den{1},'s'))
        disp(' G factored:')
        zpk(G)
        disp(' Inverse Laplace Transform:')
        gstring = simplify(ilaplace(poly2sym(G.num{1},'s')/poly2sym(G.den{1},'s')));
        % Display the inverse laplace transform
        disp('g(t) = ')
        pretty(gstring)
        
        %------------------------------------------------------------------
        % Assemble the inverse transform using residues / sum of
        % exponentials
        [R,P,K] = residue(G.num{1},G.den{1});
        
        % Expand any complex residues/poles
        cpx = find(P ~= real(P));

        numformat = ['%' num2str(numprecision+1) '.' num2str(numprecision) 'g'];

        % Complete the square on complex terms
        % Complex pairs
        gstring = '';
        for ii = 1:length(cpx)
            if ~isnan(P(cpx(ii)))
                k = find(P == P(cpx(ii)));
                kc = find(P == conj(P(cpx(ii))));
                P(kc) = NaN;
                if length(k) > 1
                    % Multiple complex poles.
                    % Won't handle it.
                    return
                end
                btcpx = conv([1,-P(cpx(ii))],[1,-conj(P(cpx(ii)))]);
                tpcpx = R(cpx(ii))*[1,-conj(P(cpx(ii)))]+conj(R(cpx(ii)))*[1,-P(cpx(ii))];
                btcpx = [1,(btcpx(2)/2),(btcpx(3)-(btcpx(2)/2)^2)^0.5];
                      % [ 1, alpha, beta]

                    btcpx = conv([1,-P(cpx(ii))],[1,-conj(P(cpx(ii)))]);
                    tpcpx = R(cpx(ii))*[1,-conj(P(cpx(ii)))]+conj(R(cpx(ii)))*[1,-P(cpx(ii))];
                    btcpx = [1,(btcpx(2)/2),(btcpx(3)-(btcpx(2)/2)^2)^0.5];
                    terms = sum((btcpx ~= [0 0 0]).*[10000 1000 100])+sum((tpcpx ~= [0 0]).*[10 1]);
                    switch terms
                        case 11111
                            %No Zeros
                            tpcpx = [tpcpx(1) tpcpx(2)/tpcpx(1)];
                            gstring = [gstring '+' num2str(tpcpx(1),numformat) '*exp(-' num2str(btcpx(2),numformat) '*t)*(cos(' num2str(btcpx(3),numformat) '*t)+'...
                                   num2str((tpcpx(2)-btcpx(2))/btcpx(3),numformat) '*sin(' num2str(btcpx(3),numformat) '*t))'];
                        case 11110
                            % Lambda == 0
                           tpcpx = [tpcpx(2)/btcpx(3) btcpx(3)];
                           gstring = [gstring '+' num2str(tpcpx(1),numformat) '*exp(-' num2str(btcpx(2),numformat) '*t)*cos(' num2str(btcpx(3),numformat) '*t)'];
                        case 11101
                            %0th order on top
                           tpcpx = [tpcpx(2)/btcpx(3) btcpx(3)];
                           gstring = [gstring '+' num2str(tpcpx(1),numformat) '*exp(-' num2str(btcpx(2),numformat) '*t)*sin(' num2str(btcpx(3),numformat) '*t)'];
                        case 11100
                            %Zero on top
                            gstring = [gstring '+ 0'];
                        case 10111
                            %Alpha is zero - no decay
                            tpcpx = [tpcpx(1) tpcpx(2)/tpcpx(1)];
                            gstring = [gstring '+' num2str(tpcpx(1),numformat) '*(cos(' num2str(btcpx(3),numformat) '*t)+'...
                                   num2str((tpcpx(2)-btcpx(2))/btcpx(3),numformat) '*sin(' num2str(btcpx(3),numformat) '*t))'];
                        case 10101
                            %0th order on top, alpha 0
                           tpcpx = [tpcpx(2)/btcpx(3) btcpx(3)];
                           gstring = [gstring '+' num2str(tpcpx(1),numformat) '*sin(' num2str(btcpx(3),numformat) '*t)'];
                        case 10110
                            %Lambda == 0, alpha 0
                           tpcpx = [tpcpx(2)/btcpx(3) btcpx(3)];
                           gstring = [gstring '+' num2str(tpcpx(1),numformat) '*sin(' num2str(btcpx(3),numformat) '*t)'];
                        case 10100
                            %Zero on top
                            gstring = [gstring '+ 0'];
                    end
            end
        end

        rl = find(P == real(P));
        % Real Poles
        for ii = [1:length(rl)]
            % find multiples
            if ~isnan(R(rl(ii)))
                k = find(P == P(rl(ii)));
                % Calculate top and bottom
                btre = [1,-P(rl(ii))];
                tpre = R(rl(ii));
                if btre(2) ~= 0
                    % alpha ~= 0
                    if tpre ~= 0
                        gstring = [gstring '+' num2str(tpre,numformat) '*exp(-' num2str(btre(2),numformat) '*t)'];
                    end
                    for n = 2:length(k)
                        if R(k(n))~=0
                            gstring = [gstring '+' num2str(R(k(n))/factorial(n-1),'%%15.15g') '*t^' ...
                                       num2str(n-1) '*exp(-' num2str(btre(2),numformat) '*t)'];
                        end
                    end
                else
                    %poles at origin
                    if tpre~=0
                        gstring = [gstring '+' num2str(tpre,numformat)];
                    end
                    for n = 2:length(k)
                        if R(k(n))~=0
                            gstring = [gstring '+' num2str(R(k(n))/factorial(n-1),numformat) '*t^' num2str(n-1)];
                        end
                    end
                end
                R(k) = NaN;
            end
        end
        % Clean up...
        gstring= strrep(gstring,'++','');
        gstring= strrep(gstring,'-+','-');
        gstring= strrep(gstring,'+-','-');
        gstring= strrep(gstring,'--','+');
        gstring= strrep(gstring,'-1*','-');
%         gstring= strrep(gstring,'+1*','+');
        gstring= strrep(gstring,'^1*','*');
        gstring= strrep(gstring,'^1+','+');
        if gstring(1) == '+'
            gstring = gstring(2:end);
        end
        
                    %         gstring = 'gstring = 0 +';
                    %         for ii = 1:length(bt)
                    %             gstring = [gstring char(ilaplace(poly2sym(tp{ii},'s')/poly2sym(bt{ii},'s'))) '+' ];
                    %         end
                    %         % Trim the + sign off the end
                    %         gstring = gstring(1:end-1);
                            % Calculate the remainder
        gstring2 = simplify(ilaplace(poly2sym(K,'s')));
        
        syms t g;
        disp('');
        disp('');
        disp(['Using Residues (' num2str(numprecision) ' digit precision):']);
        eval(['g = ' gstring ';']);
        if gstring ~= 0
            if ~isempty(gstring2) && char(gstring2) ~= '0'
                disp(['g(t) = ' char(simplify(g)) '+' char(gstring2)]);
            else
                disp(['g(t) = ' char(simplify(g))]);
            end
            disp('g(t) = ');
            pretty(simplify([g + gstring2]));
        else
            if ~isempty(gstring2)
                disp(['g(t) = ' char(gstring2)]);
                disp('g(t) = ');
                pretty(simplify(gstring2));
            else
                disp(['g(t) = 0']);
            end
        end

    else
        % Symbolic Polynomial in numerator or denominator
        syms s t;
        % Numerator
        numer = strtrim(numer);
        try
            eval(['num = ' numer ';']);
            num = collect(expand(num));
        catch
           try
                eval(['num = poly2sym([' numer '],''s'');']);
           catch
               disp(['Numerator ''' strtrim(numer) ''' is invalid.']);
               num = 1;
           end
        end

        % Denominator
        denom = strtrim(denom);
        try
            eval(['den = ' denom ';']);
            den = collect(expand(den));
            den = 1/den;
        catch
           try
                eval(['den = poly2sym([' denom '],''s'');']);
           catch
               disp(['Denominator ''' strtrim(denom) ''' is invalid.']);
               den = 1;
           end
           den = 1/den;
        end
        
        disp('G(s) =')
        pretty(num*den)
        disp('G(s) factored:')
        pretty(factor(num)*factor(den))
        disp(' Inverse Laplace Transform:')
        gstring = simplify(ilaplace(num*den,s,t));
        disp(['g(t) = ' char(gstring)])
    end
