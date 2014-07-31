%1. Import data
if ~exist('genReport','var')
    genReport = 0;
end;

if ~genReport           %Presentation mode
    %From Excel File.  Use Import wizard.  This is optional, for programmatic access
    [MAT,names] = xlsread('ValveTest_Relaxed.xls');
    for ii=1:length(names)
        eval([names{ii} '=MAT(:,' num2str(ii) ');']);
    end;
    
    %Also load full data set
    load ValveBatchTest_Relaxed

    %2.  Look at data
    figure;
    plot(time,data);
    xlabel('Time (s)');
    ylabel('Voltage (V)');
    title('Throttle Response');
    grid on
    datalabel('on','ro');

else
    %Just load from .mat file for report.  Define filename in workspace to use a different file
    %Option 2:  Load from .mat file
    if ~exist('filename','var')
        filename = 'ValveBatchTest_Relaxed';
    end;
    
    %load ValveBatchTest_Relaxed 
%    time = t;
    [Data,time] = daqread(filename);
    Data = daqtriggerreshape(Data);
    time = daqtriggerreshape(time);
    time = time(:,1);       %First vector only
    %Extract one data set
    data = Data(:,1);
end;

%Calibrate data
VpDeg = 4.5 / 90;               %Volts per degree
position = data / VpDeg;        %data in degree

if genReport                    %If generating report, load results of sptool
    load valve_sptool_export
else                            %If presenting, show sptool!
    sptool
    %Walkthrough for sptool
    %Import data
    %  - From Workspace: position
    %  - Fs = 1000
    %  - name: position
    %Look at data:
    %  - Pan around
    %  - observe slight noisiness
    %Turn on peaks and valleys.  We will use these to calculate rise, rise time
    %  - Notice that there are a bunch.  Tough to get a good measurement
    %Design a low-pass filter
    %  - We want unity gain in pass-band.
    %  - We won't worry about phase.  Since this is offline, we
    %      can use zero-phase filtering
    %  - Zoom into passband.  Try a few different filter types.  "Stumble" across Butterworth IIR
    %  - Accept default name of filt1
    %Apply filter
    %  - Select position and filt1, click Apply
    %  - Select zero phase filtering (filtfilt)
    %  - name as position_f
    %Overlay the two traces.  Show how filtered one is cleaner
    %  - Select position and position_f, click View
    %  - Select position as current trace.  Show peaks. Select position_f.  fewer peaks!
    %  - Deselect position.  Now we'll work with smoothed data
    %Explore data
    %1.  How long does it take to open, from when we issue open command?
    % - Show peaks
    %  - Add vertical marker with slope
    %  - put m1 at last peak before rise.
    %  - put m2 at next peak - end of rise
    %  - read off slope: this is rate to open, from initial command (in degrees per second)
    %2.  How fast does it really move (discount slow initial response)
    %   Or: obtain linear response
    %  - turn off peaks
    %  - slide m1 around to align slope with the majority of the rising signal
    %Export position_f and filt1 (don't use TF object)end;
end;    


%Extract data:
num = filt1.tf.num;
den = filt1.tf.den;
position_f = position_f.data;

%Find peaks and valleys
[pind,peaks] = findpeaks(position_f);        %findpeaks is extracted from fdutil, from sptool
[vind,valleys] = findpeaks(-position_f);       
valleys = -valleys;

%Find valley before rise, peak after rise
[junk,max_ind] = max(diff(peaks));
[junk,min_ind] = max(diff(valleys));

begin_ind = vind(min_ind);          %Index to last valley before open.  This indexes the original time series
end_ind = pind(max_ind+1);          %Index to first peak after open

%Calculate rise and rise time
rise_time = time(end_ind) - time(begin_ind);      %Time to open
rise = position_f(end_ind) - position_f(begin_ind);           %Difference in Voltage


%Graphics
%Compare raw and filtered data
%3 Axes:
% 211: Complete data set
% 223: Zoom in on beginning of opening
% 224: Zoom in on end of opening

figure('Tag','Filter');
subplot(211);
plot(time,position,time,position_f)
xlabel('Time (s)');
ylabel('Angle (deg)')
title('Throttle response (Relaxed to Open)');
legend('Raw Data','Filtered Data',4);
subplot(223);
plot(time,position,time,position_f)
xlabel('Time (s)');
ylabel('Angle (deg)')
title('Begin');
axis([-.15 -.1 22.7 23.2]);
subplot(224);
plot(time,position,time,position_f)
xlabel('Time (s)');
ylabel('Angle (deg)')
title('End');
axis([.06 .18 82.8 86.9]);

%legend('Raw Data','Filtered Data');

%Algorithm Design
%This shows peaks and valleys identified in the signal.
%The two points used for calculations are identified.
figure('Tag','Algorithm');
plot(time,position_f,time(pind),peaks,'^',time(vind),valleys,'v')
xlabel('Time (s)');
ylabel('Angle (deg)')
title('Throttle response (Relaxed to Open)');
hold on;
ph = plot(time(begin_ind),valleys(min_ind),'rv',time(end_ind),peaks(max_ind+1),'g^');
set(ph,'MarkerFaceColor','k')
legend('Position','Peaks','Valleys','Begin','End',4);

t1=time(begin_ind);
t2=time(end_ind);
m1=valleys(min_ind);
m2=peaks(max_ind+1);
%Label rise time
line([t1;t2],[m1;m1],'Color','k','LineStyle','-.');
text(mean([t1 t2]),m1,{'Rise Time: '; [num2str(rise_time) ' s']}, ...
    'HorizontalAlignment','Center', ...
    'VerticalAlignment','Bottom', ...
    'FontWeight','Bold');
%Label rise
line([t1;t1],[m1;m2],'Color','k','LineStyle','-.');
text(t1,mean([m1 m2]),{'Rise: '; [num2str(rise) ' \circ']}, ...
    'HorizontalAlignment','Center', ...
    'FontWeight','Bold');
