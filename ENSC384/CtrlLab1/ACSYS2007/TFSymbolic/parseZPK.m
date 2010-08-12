function tfout = parseZPK(TFin);
    % TFin - In form [zeros;poles;gain]
    try
        tfout = zpk(str2num(TFin(1,:)),str2num(TFin(2,:)),str2num(TFin(3,:)));
    catch
        disp('Invalid entry: ');
        disp(['Zeros' TFin(1,:)]);
        disp(['Poles' TFin(2,:)]);
        disp(['Gain' TFin(3,:)]);
        tfout = tf(0,1);
    end