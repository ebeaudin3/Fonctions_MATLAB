%throttle_simulation_stopfcn1run  Stop Function for throttle simulation when run once
%Prepare some measured data
%Try to use the data we just recorded.  This should be stored in a 
% file named filename.  If we can't find it, use a stored data set.
if ~exist('filename','var')
    filename = 'ValveBatchTest_Relaxed';
    disp('Loading pre-saved data');
end;

%Load and reshape data
[Data,time] = daqread(filename);
Data = daqtriggerreshape(Data); %NSamples x NTriggers
time = daqtriggerreshape(time); %NSamples x NTriggers
time = time(:,1);       %Keep First vector only

%Load filter
if ~exist('filt1','var')                        %From sptool
    load valve_sptool_export
    
    %Extract data:
    num = filt1.tf.num;
    den = filt1.tf.den;
end;

%Filter the data.  If we use pre-recorded data, just use the first run.
data = filtfilt(num,den,Data(:,1));

%Calibrate
VpDeg = 4.5 / 90;               %Volts per degree
position = data / VpDeg;

%Apply algorithm to find transition points
[t_c,p_c] = find_transition(position,time);

%Get data from simulation (stored in scope)
tout = ScopeData.time;
position_s = ScopeData.signals.values;

%Run analysis on simulated data
[t_cs,p_cs] = find_transition(position_s,tout);

%Compare measured and simulated data
%The simulation is already informed of the measurement:
%  The hard stops are defined based on the measured data
figure('Tag','Simulation');
ph =plot(time,position,'b',tout,position_s,'r', ...
    t_c(2),p_c(2),'b^',t_c(1),p_c(1),'bv', ...
    t_cs(2),p_cs(2),'r^',t_cs(1),p_cs(1),'rv');
set(ph,'MarkerFaceColor','k','LineWidth',2)
xlabel('Time (s)');
ylabel('Angle (deg)')
title('Throttle response (Relaxed to Open)');

legend('Measured','Simulated',4);
