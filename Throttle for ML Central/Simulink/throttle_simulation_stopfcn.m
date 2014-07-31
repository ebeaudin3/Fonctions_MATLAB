%throttle_simulation_stopfcn  Stop function for throttle simulation (duh)
%Display a comparison of measured and simulated data.  This file is for use by
%throttle_simulation_validate, which is sweeping the stiffness parameter (k).  One
%subplot is created for each run


tout = ScopeData.time;
position_s = ScopeData.signals.values;


%I have hardcoded the time for the step input into the model.
%This directly impacts the time at which the response begins
% to rise.  This needs to match the measured data.
%This gives a great response for one throttle I've tested,
% but not necessarily for the others.  
%Here, I try to match up the measured and simulated time history
% at the trigger value.  The measured data triggers at 0 seconds.
% Shift the simulated data so that it matches the measured data
% at this time.

%Find trigger value in measured data. Should be 60 degrees (trigger at 3V=60 deg)
trig_ind = find(time==0);
trig_value = position(trig_ind);       

%Find the time at which the simulated response matches this value
[junk,trig_ind_s] = min(abs(position_s - trig_value));
trig_time_s = tout(trig_ind_s);

%Correct the time basis so that they match at t=0 sec.
tout = tout - trig_time_s;

%In order to be able to compute error, we actually need to shift the simulation output
shift = trig_ind_s - trig_ind;  %Shift to line up.
if shift<0      %Delay simulated response
    shift_ind = (1:(length(tout))+shift)';
else            %Push up simulated response earlier
    shift_ind = (1+shift:length(tout))';
end;
position_s = position_s(shift_ind);
tout = tout(shift_ind);
%position_s and tout are a little bit shorter than they started!

%Plot the simulated and measured data
subplot_varspace(4,4,ii,[],0.025);  %Tight subplots
ph =plot(time,position,'b',tout,position_s,'r','LineWidth',2);
set(gca,'XTick',[],'YTick',[],'Tag',num2str(ii));
axis([time(1) time(end) 20 90]);
ax = axis;
text(mean(ax(1:2)),mean(ax(3:4)),['k=' num2str(k)])

%Compute the error.
%Since position_s is now shorter than position, I need to play
% a bit of a game.  I need to shorten position, too.  I don't 
% know if this will make sense to you, but I do the "opposite"
% shift for position than I used for position_s.  Likewise, I
% store only these values into E.  Don't worry about the others - 
% they all = 0 and won't impact the least squares calculation.
E(shift_ind-shift,ii) = position(shift_ind-shift) - position_s;
