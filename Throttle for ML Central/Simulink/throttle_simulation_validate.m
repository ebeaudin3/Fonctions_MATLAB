%throttle_simulation_validate   Parameter sweep to match simulation to measured data

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


%Prepare simulation
model_name = 'throttle_simulation';
open(model_name)

%Compute stops for model
angle_init  = mean(position(1:100)) / 90;           %Initial position
angle_maxopen = max(position)/ 90;                  %Upper limit
angle_open  =  mean(position(end-100:end)) / 90;    %Open 

%Parameter sweep to find good values
figure('Visible','off','Tag','Simulation');
fillscreen
set(gcf,'Visible','on')

stopfcn = get_param(bdroot,'StopFcn');

%Set stop function to add a subplot to the figure for each run
set_param(bdroot,'StopFcn','throttle_simulation_stopfcn');
KK = .8:.1:2.3;
ii=0;


E=zeros(length(position),length(KK));   
%Error: Measured_Position - Simulated_Position
%Computed in throttle_simulation_stopfcn
%Notice: simulation and test are run over the same
% time basis, so we can make this comparison directly
% from the raw time series.  There is a bit of manipulation
% to ensure that the time series line up properly.

%Run simulation parameter sweep
for k=KK;
    ii=ii+1;        %Counter; used for subplot index
    sim(model_name); 
end;

%Find best run by looking at least square of error
lsqE = diag(E'*E);  %Quick least squares error calculation
[minE,k_opt_ind] = min(lsqE);
k_opt = KK(k_opt_ind);  %"Optimal" stiffness parameter

suptitle({'Parameter Sweep: Stiffness Coefficient',
    ['k_{opt}=' num2str(k_opt)]})
ax = findobj('Type','Axes','Tag',num2str(k_opt_ind));
set(ax,'Color','y')

%Reset the stopfcn
set_param(bdroot,'StopFcn',stopfcn);

