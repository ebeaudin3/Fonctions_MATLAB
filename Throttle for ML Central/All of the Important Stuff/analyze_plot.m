%analyze_plot   Demonstrate the algorithm developed with sptool

%Failsafe.  Load data if necessary
if ~exist('position','var') | ~exist('time','var')  %From Excel
    load ValveTestRelaxed
    VpDeg = 4.5 / 90;               %Volts per degree
    position = data / VpDeg;        %data in degree
    disp('Loading pre-saved data');
end;
if ~exist('filt1','var')                        %From sptool
    load valve_sptool_export
    disp('Loading pre-designed filter');
end;


%Extract data:
num = filt1.tf.num;
den = filt1.tf.den;
position_f = filtfilt(num,den,position);

%Apply algorithm
%Find peaks and valleys
[pind,peaks] = findpeaks(position_f);        %findpeaks is extracted from fdutil, from sptool
[vind,valleys] = findpeaks(-position_f);       
valleys = -valleys;

%Find valley before rise, peak after rise
%Need special case for first peak after critical valley

[junk,min_ind] = max(diff(valleys));
begin_ind = vind(min_ind);          %Index to last valley before open.  This indexes the original time series


if begin_ind < pind(1)  %Special case.  Take the first peak
    max_ind = 0;
    end_ind = pind(1);
else
    [junk,max_ind] = max(diff(peaks));
    end_ind = pind(max_ind+1);          %Index to first peak after open
end;

    
%Calculate rise and rise time
rise_time = time(end_ind) - time(begin_ind);      %Time to open
rise = position_f(end_ind) - position_f(begin_ind);           %Difference in Voltage

t_c=[time(begin_ind);time(end_ind)];
p_c=[valleys(min_ind);peaks(max_ind+1)];

%Compute rise and rise_time
rise=diff(p_c);
rise_time = diff(t_c);


%Graphics
%Compare raw and filtered data
%3 Axes:
% 211: Complete data set
% 223: Zoom in on beginning of opening
% 224: Zoom in on end of opening

f1 = figure('Tag','Filter');
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
axis([-.15 -.1 valleys(min_ind)-.2 valleys(min_ind)+.3]);
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
datalabel('on','ro');

figure(f1);