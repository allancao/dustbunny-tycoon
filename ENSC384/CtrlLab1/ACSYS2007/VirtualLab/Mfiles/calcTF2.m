% calcTF
% Calculates the system transfer functions using Motor physical and control
% parameters from SIMLab Simulink Models.  Returns transfer functions in
% the form of a latex string.
% numericTF - a MATLAB Structure of Latex Strings
%         numericTF.tf3rdOstr : Closed Loop Expression calculated with L
%         numericTF.tf2ndOstr : Closed Loop Expression, approximating L = 0
%         numericTF.motor3OL : Open Loop Motor Transfer Function calculated
%         with L
%         numericTF.motor2OL : Open Loop Motor Transfer Function, L = 0
% symbolTF - a MATLAB Structure of Latex Strings
%         symbolTF.tf3rdOsym : Closed Loop Expression calculated with L
%         symbolTF.tf2ndOsym : Closed Loop Expression, approximating L = 0
%         symbolTF.motor3OLsym : Open Loop Motor Transfer Function calculated
%         with L
%         symbolTF.motor2OLsym : Open Loop Motor Transfer Function, L = 0

function [numericTF symbolTF] = calcTF2(vars)

numericTF = struct;
symbolTF = struct;

if strcmp(vars.response_type,'Position')
    typeString = 'Theta(s)';
        [numericTF symbolTF] = calcTFpos(vars);
    return;
else
    typeString = 'Omega(s)';
end

if any(isnan([vars.P vars.I vars.D]))
     if (vars.L ~= 0)       
        motor3OLnum = [2*vars.Km/vars.L/vars.J];
        motor3OLden = [1 (vars.J*vars.R + vars.b*vars.L)/vars.J/vars.L (vars.R*vars.b + vars.Kb*vars.Km)/vars.J/vars.L];
        motor3OLsym = '\frac{k_ak_m}{JL}\cdot\frac{1}{s^2+\frac{JR+bL}{JL}s+\frac{Rb+k_bk_m}{JL}}$';
        motor3OL = sprintf('$\\%s = %4.3g \\cdot \\frac{1}{s^{2} + %4.3gs + %4.3g}$', typeString, motor3OLnum,motor3OLden(2:end));
     else
        motor3OL = sprintf('$0 \\cdot \\frac{0}{1}$');
        motor3OLsym = '0\cdot\frac{0}{1}$';
     end
        motor2OLnum = [2*vars.Km/vars.R/vars.J];
        motor2OLden = [1 (vars.R*vars.b + vars.Kb*vars.Km)/vars.J/vars.R];
        motor2OL = sprintf('$\\%s = %4.3g \\cdot \\frac{1}{s + %4.3g}$', typeString, motor2OLnum,motor2OLden(2:end));  
        
        tf3rdOstr = sprintf('$0 \\cdot \\frac{0}{1}$');
        tf2ndOstr = sprintf('$0 \\cdot \\frac{0}{1}$');
        tf2ndOsym = '0\cdot\frac{0}{1}$';
        tf3rdOsym = '0\cdot\frac{0}{1}$';
        
        motor3OL = cleanExps(motor3OL);
        motor2OLsym = '\frac{k_ak_m}{JR}\cdot\frac{1}{s+\frac{Rb+k_bk_m}{JR}}$';
        motor2OL = cleanExps(motor2OL);
        
        numericTF.tf3rdOstr = tf3rdOstr;
        numericTF.tf2ndOstr = tf2ndOstr;
        numericTF.motor3OL = motor3OL;
        numericTF.motor2OL = motor2OL;
        
        symbolTF.tf3rdOsym = ['$\' typeString ' = ' tf3rdOsym];
        symbolTF.tf2ndOsym = ['$\' typeString ' = ' tf2ndOsym];
        symbolTF.motor3OLsym = ['$\' typeString ' = ' motor3OLsym];
        symbolTF.motor2OLsym = ['$\' typeString ' = ' motor2OLsym];
        
        return;
end


% Third Order TF
    if (vars.L ~= 0)
        if vars.D ~= 0
            vars.num3rdO = [1 vars.P/vars.D vars.I/vars.D];
            vars.den3rdO = [1, vars.b/vars.J + vars.R/vars.L + vars.D*2*vars.Km/vars.J/vars.L,...
                (vars.R*vars.b + vars.P*2*vars.Km + vars.Km*vars.Kb)/vars.J/vars.L, vars.I*2*vars.Km/vars.J/vars.L];
            vars.gain3rdO = [2*vars.Km*vars.D/vars.J/vars.L];
            tf3rdOsym = '\frac{k_ak_mk_d}{JL}\cdot\frac{s^2+\frac{k_p}{k_d}s+\frac{k_i}{k_d}}{s^3+\frac{bL+JR+k_dk_ak_m}{JL}s^2+\frac{Rb+k_pk_ak_m+k_bk_m}{JL}s+\frac{k_ik_ak_m}{JL}}$';
            tf3rdOstr = sprintf('$\\%s = %4.3g \\cdot \\frac{s^{2} + %4.3gs + %4.3g}{s^{3} + %4.3gs^{2} + %4.3gs + %4.3g}$', typeString, vars.gain3rdO,vars.num3rdO(2:end),vars.den3rdO(2:end));
        else if vars.P ~= 0
                vars.num3rdO = [1 vars.I/vars.P];
                vars.den3rdO = [1, vars.b/vars.J + vars.R/vars.L + vars.D*2*vars.Km/vars.J/vars.L,...
                    (vars.R*vars.b + vars.P*2*vars.Km + vars.Km*vars.Kb)/vars.J/vars.L, vars.I*2*vars.Km/vars.J/vars.L];
                vars.gain3rdO = [vars.P*2*vars.Km/vars.J/vars.L];
                tf3rdOsym = '\frac{k_ak_mk_p}{JL}\cdot\frac{s+\frac{k_i}{k_p}}{s^3+\frac{bL+JR}{JL}s^2+\frac{Rb+k_pk_ak_m+k_bk_m}{JL}s+\frac{k_ik_ak_m}{JL}}$';
                tf3rdOstr = sprintf('$\\%s = %4.3g \\cdot \\frac{s + %4.3g}{s^{3} + %4.3gs^{2} + %4.3gs + %4.3g}$', typeString, vars.gain3rdO,vars.num3rdO(2:end),vars.den3rdO(2:end));   
            else
                vars.den3rdO = [1, vars.b/vars.J + vars.R/vars.L + vars.D*2*vars.Km/vars.J/vars.L,...
                    (vars.R*vars.b + vars.P*2*vars.Km + vars.Km*vars.Kb)/vars.J/vars.L, vars.I*2*vars.Km/vars.J/vars.L];
                vars.num3rdO = [1];
                vars.gain3rdO = [vars.I*2*vars.Km/(vars.J*vars.R + vars.D*2*vars.Km)];
                tf3rdOsym = '\frac{k_ak_mk_i}{JL}\cdot\frac{1}{s^3+\frac{bL+JR}{JL}s^2+\frac{Rb+k_bk_m}{JL}s+\frac{k_ik_ak_m}{JL}}$';
                tf3rdOstr = sprintf('$\\%s = %4.3g \\cdot \\frac{1}{s^{3} + %4.3gs^{2} + %4.3gs + %4.3g}$', typeString, vars.gain3rdO,vars.den3rdO(2:end));
             end
        end

        motor3OLnum = [2*vars.Km/vars.L/vars.J];
        motor3OLden = [1 (vars.J*vars.R + vars.b*vars.L)/vars.J/vars.L (vars.R*vars.b + vars.Kb*vars.Km)/vars.J/vars.L];
        motor3OLsym = '\frac{k_ak_m}{JL}\cdot\frac{1}{s^2+\frac{JR+bL}{JL}s+\frac{Rb+k_bk_m}{JL}}$';
        motor3OL = sprintf('$\\%s = %4.3g \\cdot \\frac{1}{s^{2} + %4.3gs + %4.3g}$', typeString, motor3OLnum,motor3OLden(2:end));
        
    else 
            vars.num3rdO = 0;
            vars.den3rdO = 0;
            vars.gain3rdO = 0;
            vars.tf3rdO = 0;
            tf3rdOstr = sprintf('$0 \\cdot \\frac{0}{1}$');
            motor3OL = sprintf('0 \\cdot \\frac{0}{1}$');
    end

 % Simplified Second Order TF
    if vars.D ~= 0
        vars.num2ndO = [1 vars.P/vars.D vars.I/vars.D];
        vars.den2ndO = [1, (vars.R*vars.b + vars.P*2*vars.Km + vars.Kb*vars.Km)/(vars.J*vars.R + vars.D*2*vars.Km),...
                        vars.I*vars.Km*2/(vars.J*vars.R + vars.D*2*vars.Km)];
        vars.gain2ndO = [vars.D*2*vars.Km/(vars.J*vars.R + vars.D*2*vars.Km)];
        tf2ndOsym = '\frac{k_ak_mk_d}{JR+k_ak_mk_d}\cdot\frac{s^2+\frac{k_p}{k_d}s+\frac{k_i}{k_d}}{s^2+\frac{Rb+k_pk_ak_m+k_bk_m}{JR+k_ak_mk_d}s+\frac{k_ik_ak_m}{JR+k_ak_mk_d}}$';
        tf2ndOstr = sprintf('$\\%s = %4.3g \\cdot \\frac{s^{2} + %4.3gs + %4.3g}{s^{2} + %4.3gs + %4.3g}$', typeString, vars.gain2ndO,vars.num2ndO(2:end),vars.den2ndO(2:end));
    else if vars.P ~= 0
        vars.num2ndO = [1 vars.I/vars.P];
        vars.den2ndO = [1, (vars.R*vars.b + vars.P*2*vars.Km + vars.Kb*vars.Km)/(vars.J*vars.R + vars.D*2*vars.Km),...
                        vars.I*vars.Km*2/(vars.J*vars.R + vars.D*2*vars.Km)];
        vars.gain2ndO = [vars.P*2*vars.Km/(vars.J*vars.R + vars.D*2*vars.Km)];
        tf2ndOsym = ' \frac{k_ak_mk_p}{JR}\cdot\frac{s+\frac{k_i}{k_p}}{s^2+\frac{Rb+k_pk_ak_m+k_bk_m}{JR}s+\frac{k_ik_ak_m}{JR}}$';
        tf2ndOstr = sprintf('$\\%s = %4.3g \\cdot \\frac{s + %4.3g}{s^{2} + %gs + %4.3g}$', typeString, vars.gain2ndO,1.22231245353453e16,vars.den2ndO(2:end));
        else
            vars.den2ndO = [1, (vars.R*vars.b + vars.P*2*vars.Km + vars.Kb*vars.Km)/(vars.J*vars.R + vars.D*2*vars.Km),...
                        vars.I*vars.Km*2/(vars.J*vars.R + vars.D*2*vars.Km)];
            vars.num2ndO = [1];
            vars.gain2ndO = [vars.I*2*vars.Km/(vars.J*vars.R + vars.D*2*vars.Km)];
            tf2ndOsym = '\frac{k_ak_mk_i}{JR}\cdot\frac{1}{s^2+\frac{Rb+k_bk_m}{JR}s+\frac{k_ik_ak_m}{JR}}$';
            tf2ndOstr = sprintf('$\\%s = %4.3g \\cdot \\frac{1}{s^{2} + %4.3gs + %4.3g}$', typeString, vars.gain2ndO,vars.den2ndO(2:end));
        end
    end
    %vars.tf2ndO = tf(vars.num2ndO, vars.den2ndO);

    % Clean up for display purposes

    motor2OLnum = [2*vars.Km/vars.R/vars.J];
    motor2OLden = [1 (vars.R*vars.b + vars.Kb*vars.Km)/vars.J/vars.R];
    motor2OLsym = '\frac{k_ak_m}{JR}\cdot\frac{1}{s+\frac{Rb+k_bk_m}{JR}}$';
    motor2OL = sprintf('$\\%s = %4.3g \\cdot \\frac{1}{s + %4.3g}$', typeString, motor2OLnum,motor2OLden(2:end));
    
    
    tf3rdOstr = cleanExps(tf3rdOstr);
    tf2ndOstr = cleanExps(tf2ndOstr);
    motor3OL = cleanExps(motor3OL);
    motor2OL = cleanExps(motor2OL);
    
        numericTF.tf3rdOstr = tf3rdOstr;
        numericTF.tf2ndOstr = tf2ndOstr;
        numericTF.motor3OL = motor3OL;
        numericTF.motor2OL = motor2OL;
        
        symbolTF.tf3rdOsym = ['$\' typeString ' = ' tf3rdOsym];
        symbolTF.tf2ndOsym = ['$\' typeString ' = ' tf2ndOsym];
        symbolTF.motor3OLsym = ['$\' typeString ' = ' motor3OLsym];
        symbolTF.motor2OLsym = ['$\' typeString ' = ' motor2OLsym];
          
%-----------------------------------------------------------------       
%       Start of calcTFpos
%-----------------------------------------------------------------   
 function [numericTF symbolTF] = calcTFpos(vars)

numericTF = struct;
symbolTF = struct;

if strcmp(vars.response_type,'Position')
    typeString = 'Theta(s)';
else
    typeString = 'Omega(s)';
end

P = vars.P; I = vars.I; D = vars.D; 
Km = vars.Km; b = vars.b; L = vars.L; 
J = vars.J; R = vars.R; Kb = vars.Kb;

if any(isnan([vars.P vars.I vars.D]))
     if (vars.L ~= 0)       
        motor3OLnum = [2*vars.Km/vars.L/vars.J];
        motor3OLden = [1 (vars.J*vars.R + vars.b*vars.L)/vars.J/vars.L (vars.R*vars.b + vars.Kb*vars.Km)/vars.J/vars.L];
        motor3OLsym = '\frac{k_ak_m}{JL}\cdot\frac{1}{s}\cdot\frac{1}{s^2+\frac{JR+bL}{JL}s+\frac{Rb+k_bk_m}{JL}}$';
        motor3OL = sprintf('$\\%s = %4.3g \\cdot\\frac{1}{s}\\cdot\\frac{1}{s^{2} + %4.3gs + %4.3g}$', typeString, motor3OLnum,motor3OLden(2:end));
     else
        motor3OL = sprintf('$0 \\cdot \\frac{0}{1}$');
        motor3OLsym = '0\cdot\frac{0}{1}$';
     end
        motor2OLnum = [2*vars.Km/vars.R/vars.J];
        motor2OLden = [1 (vars.R*vars.b + vars.Kb*vars.Km)/vars.J/vars.R];
        motor2OL = sprintf('$\\%s = %4.3g \\cdot\\frac{1}{s}\\cdot\\frac{1}{s + %4.3g}$', typeString, motor2OLnum,motor2OLden(2:end));  
        
        tf3rdOstr = sprintf('$0 \\cdot \\frac{0}{1}$');
        tf4thOstr = sprintf('$0 \\cdot \\frac{0}{1}$');
        tf4thOsym = '0\cdot\frac{0}{1}$';
        tf3rdOsym = '0\cdot\frac{0}{1}$';
        
        motor3OL = cleanExps(motor3OL);
        motor2OLsym = '\frac{k_ak_m}{JR}\cdot\frac{1}{s}\cdot\frac{1}{s+\frac{Rb+k_bk_m}{JR}}$';
        motor2OL = cleanExps(motor2OL);
        
        numericTF.tf3rdOstr = tf4thOstr;
        numericTF.tf2ndOstr = tf2ndOstr;
        numericTF.motor3OL = motor3OL;
        numericTF.motor2OL = motor2OL;
        
        symbolTF.tf3rdOsym = ['$\' typeString ' = ' tf4thOsym];
        symbolTF.tf2ndOsym = ['$\' typeString ' = ' tf3rdOsym];
        symbolTF.motor3OLsym = ['$\' typeString ' = ' motor3OLsym];
        symbolTF.motor2OLsym = ['$\' typeString ' = ' motor2OLsym];
        
        return;
end


% Third Order TF
    if (vars.L ~= 0)
        if vars.D ~= 0
            tf4thOnum = [1 P/D I/D];
            tf4thOden = [1 (b*L+R*J)/J/L (R*b+ Kb*Km+ 2*Km*D)/J/L 2*Km*P/J/L I*2*Km/J/L];
            tf4thOgain = 2*Km*D/J/L;
            tf4thOstr = sprintf('$\\%s = %4.3g \\cdot \\frac{s^{2} + %4.3gs + %4.3g}{s^{4} + %4.3gs^{3} + %4.3gs^{2} + %4.3gs + %4.3g}$', typeString, tf4thOgain,tf4thOnum(2:end),tf4thOden(2:end));
            tf4thOsym = '\frac{k_ak_mk_d}{JL}\cdot\frac{s^2+\frac{k_p}{k_d}s+\frac{k_i}{k_d}}{s^4+\frac{bL+RJ}{JL}s^3+\frac{bR+k_ak_mk_d+k_bk_m}{JL}s^2+\frac{k_ak_mk_p}{JL}s+\frac{k_ik_mk_a}{JL}}$';

        else if vars.P ~= 0
                tf4thOnum = [1 I/P];
                tf4thOden = [1 (b*L+R*J)/J/L (R*b+ Kb*Km)/J/L 2*Km*P/J/L I*2*Km/J/L];
                tf4thOgain = 2*Km*P/J/L;
                tf4thOstr = sprintf('$\\%s = %4.3g \\cdot \\frac{s + %4.3g}{s^{4} + %4.3gs^{3} + %4.3gs^{2} + %4.3gs + %4.3g}$', typeString, tf4thOgain,tf4thOnum(2:end),tf4thOden(2:end));
                tf4thOsym = '\frac{k_ak_mk_p}{JL}\cdot\frac{s+\frac{k_i}{k_p}}{s^4+\frac{bL+RJ}{JL}s^3+\frac{bR+k_bk_m}{JL}s^2+\frac{k_ak_mk_p}{JL}s+\frac{k_ik_mk_ap}{JL}}$';
            else
                tf4thOnum = [1];
                tf4thOden = [1 (b*L+R*J)/J/L (R*b+ Kb*Km)/J/L 0 I*2*Km/J/L];
                tf4thOgain = 2*Km*I/J/L;
                tf4thOstr = sprintf('$\\%s = %4.3g \\cdot \\frac{1}{s^{4} + %4.3gs^{3} + %4.3gs^{2} + %4.3gs + %4.3g}$', typeString, tf4thOgain,tf4thOden(2:end));
                tf4thOsym = '\frac{k_ak_mk_i}{JL}\cdot\frac{1}{s^4+\frac{bL+RJ}{JL}s^3+\frac{bR+k_bk_m}{JL}s^2+\frac{k_ik_mk_a}{JL}}$';
             end
        end

        motor3OLnum = [2*vars.Km/vars.L/vars.J];
        motor3OLden = [1 (vars.J*vars.R + vars.b*vars.L)/vars.J/vars.L (vars.R*vars.b + vars.Kb*vars.Km)/vars.J/vars.L];
        motor3OLsym = '\frac{k_ak_m}{JL}\cdot\frac{1}{s}\cdot\frac{1}{s^2+\frac{JR+bL}{JL}s+\frac{Rb+k_bk_m}{JL}}$';
        motor3OL = sprintf('$\\%s = %4.3g \\cdot\\frac{1}{s}\\cdot\\frac{1}{s^{2} + %4.3gs + %4.3g}$', typeString, motor3OLnum,motor3OLden(2:end));
        
    else 
            vars.num3rdO = 0;
            vars.den3rdO = 0;
            vars.gain3rdO = 0;
            vars.tf3rdO = 0;
            tf4thOstr = sprintf('$0 \\cdot \\frac{0}{1}$');
            motor3OL = sprintf('0 \\cdot \\frac{0}{1}$');
    end

 % Simplified Second Order TF
    if vars.D ~= 0
        tf3rdOnum = [1 P/D I/D];
        tf3rdOden = [1 (R*b+ Kb*Km+ 2*Km*D)/J/R 2*Km*P/J/R I*2*Km/J/R];
        tf3rdOgain = 2*Km*D/J/R;
        tf3rdOstr = sprintf('$\\%s = %4.3g \\cdot \\frac{s^{2} + %4.3gs + %4.3g}{s^{3} + %4.3gs^{2} + %4.3gs + %4.3g}$', typeString, tf3rdOgain,tf3rdOnum(2:end),tf3rdOden(2:end));
        tf3rdOsym = '\frac{k_ak_mk_d}{JR}\cdot\frac{s^2+\frac{k_p}{k_d}s+\frac{k_i}{k_d}}{s^3+\frac{bR+k_ak_mk_d+k_bk_m}{JR}s^2+\frac{k_ak_mk_p}{JR}s+\frac{k_ik_mk_a}{JR}}$';
    else if vars.P ~= 0
            tf3rdOnum = [1 I/P];
            tf3rdOden = [1 (R*b+ Kb*Km)/J/R 2*Km*P/J/R I*2*Km/J/R];
            tf3rdOgain = 2*Km*P/J/R;
            tf3rdOstr = sprintf('$\\%s = %4.3g \\cdot \\frac{s + %4.3g}{s^{3} + %4.3gs^{2} + %4.3gs + %4.3g}$', typeString, tf3rdOgain,tf3rdOnum(2:end),tf3rdOden(2:end));
            tf3rdOsym = '\frac{k_ak_mk_p}{JR}\cdot\frac{s+\frac{k_i}{k_p}}{s^3+\frac{bR+k_bk_m}{JR}s^2+\frac{k_ak_mk_p}{JR}s+\frac{k_ik_mk_a}{JR}}$';
        else
            tf3rdOnum = [1];
            tf3rdOden = [1 (R*b+ Kb*Km)/J/R 0 I*2*Km/J/R];
            tf3rdOgain = 2*Km*I/J/L;
            tf3rdOstr = sprintf('$\\%s = %4.3g \\cdot \\frac{1}{s^{3} + %4.3gs^{2} + %4.3gs + %4.3g}$', typeString, tf3rdOgain,tf3rdOden(2:end));
            tf3rdOsym = '\frac{k_ak_mk_i}{JR}\cdot\frac{1}{s^3+\frac{bR+k_bk_m}{JR}s^2+\frac{k_ik_mk_a}{JR}}$';
        end
    end
    
    % Clean up for display purposes

        motor2OLnum = [2*vars.Km/vars.R/vars.J];
        motor2OLden = [1 (vars.R*vars.b + vars.Kb*vars.Km)/vars.J/vars.R];
        motor2OL = sprintf('$\\%s = %4.3g \\cdot\\frac{1}{s}\\cdot\\frac{1}{s + %4.3g}$', typeString, motor2OLnum,motor2OLden(2:end));  
        motor2OLsym = '\frac{k_ak_m}{JR}\cdot\frac{1}{s}\cdot\frac{1}{s+\frac{Rb+k_bk_m}{JR}}$';
    
        tf4thOstr = cleanExps(tf4thOstr);
        tf3rdOstr = cleanExps(tf3rdOstr);
        motor3OL = cleanExps(motor3OL);
        motor2OL = cleanExps(motor2OL);
    
        numericTF.tf3rdOstr = tf4thOstr;
        numericTF.tf2ndOstr = tf3rdOstr;
        numericTF.motor3OL = motor3OL;
        numericTF.motor2OL = motor2OL;
        
        symbolTF.tf3rdOsym = ['$\' typeString ' = ' tf4thOsym];
        symbolTF.tf2ndOsym = ['$\' typeString ' = ' tf3rdOsym];
        symbolTF.motor3OLsym = ['$\' typeString ' = ' motor3OLsym];
        symbolTF.motor2OLsym = ['$\' typeString ' = ' motor2OLsym];
        
%-----------------------------------------------------------------       
%       End of calcTFpos
%-----------------------------------------------------------------      
 
%-----------------------------------------------------------------       
%       Start of cleanExps
%-----------------------------------------------------------------  
     function instring = cleanExps(instring)
        exps = findstr(instring,'e+');
        maxn = length(exps);
        if ~isempty(exps)
            for ii = 1:maxn
                if isempty(exps) break; end
                instring = strrep(instring,instring(exps(1):exps(1)+4),['\cdot 10^{' instring(exps(1)+2:exps(1)+4) '}']);
                exps = findstr(instring,'e+');
            end
        end

        exps = findstr(instring,'e-');
        maxn = length(exps);
        if ~isempty(exps)
            for ii = 1:maxn
                if isempty(exps) break; end
                instring = strrep(instring,instring(exps(1):exps(1)+4),['\cdot 10^{-' instring(exps(1)+2:exps(1)+4) '}']);
                exps = findstr(instring,'e-');
            end
        end
%-----------------------------------------------------------------       
%       End of cleanExps
%-----------------------------------------------------------------  