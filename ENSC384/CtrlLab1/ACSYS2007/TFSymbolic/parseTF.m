function tfout = parseTF(numer,denom,vars);

    

    % Just in case...
    s = tf('s');
    
    try
        % Numerator
        if any(numer == 's');
            eval(['num = ' numer ';']);
        else
            num = tf(str2num(numer),[1]);
        end
    catch
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
    tfout = num*den;