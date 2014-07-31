function [t,position] = plotdata(ai);
%plotdata               Get and plot one triggers worth of data
%
%  plotdata(ai);
%ai:   Analog input object.  Configured with CreateAI.

% Copyright 2002 - 2003 The MathWorks, Inc

try
    [d,t] = getdata(ai,ai.SamplesPerTrigger);    %Get 1 trigger of data
catch
    disp('Sorry.  No data available')
    t = (0:1:999)*.001;
    d = ones(size(t));
    return
end;

%Calibrate data
VpDeg = 4.5 / 90;               %Volts per degree
position = d / VpDeg;        %data in degree

figure;
plot(t,position);
xlabel('Time (s)');
ylabel('Angle (deg)');
title('Throttle Response');
grid on
datalabel('on','ro');