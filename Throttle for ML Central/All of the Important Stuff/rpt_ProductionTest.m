%Production Test.  Calculate rise and rise time for a large
% batch of throttles.  Compare performance to some standard
% to determine if it passes or fails.
if ~exist('genReport','var')
    genReport=0;
end;


if ~genReport
    load ValveBatchTest_Relaxed
end;

VpDeg = 4.5 / 90;               %Volts per degree
if ~exist('filt1','var')                        %From sptool
    load valve_sptool_export
    
    %Extract data:
    num = filt1.tf.num;
    den = filt1.tf.den;
end;


%Filter all test data
Position = Data / VpDeg;    %data in degree; all records
Position_f = filtfilt(num,den,Position); %Apply Filter to ALL records

[NSamples, NTests] = size(Position);        %Number samples per test; number of tets

%Compute Rise and Rise_Time for each test.
Rise_Time = zeros(1,NTests);
Rise      = zeros(1,NTests);

Begin_ind = zeros(1,NTests);                %Sample at which transition begins
End_ind  = zeros(1,NTests);                 %Sample at which transition ends
% Close     = zeros(1,NTests);
% Open      = zeros(1,NTests);

%Save intermediate data for appendix
Peaks = {};
Valleys = {};
Pind = {};
Vind = {};

for ii=1:NTests
    [pind,peaks] = findpeaks(Position_f(:,ii));        %One long vector
    [vind,valleys] = findpeaks(-Position_f(:,ii));     
    valleys = -valleys;
    
    Peaks{ii}   = peaks;
    Valleys{ii} = valleys;
    Pind{ii}    = pind;
    Vind{ii}    = vind;
    
    [junk,max_ind] = max(diff(peaks));
    [junk,min_ind] = max(diff(valleys));
    closed_ind = vind(min_ind);          %Index to last valley before open.  This indexes the original time series
    open_ind = pind(max_ind+1);          %Index to first peak after open
    
    Begin_ind(ii) = closed_ind;
    End_ind(ii)   = open_ind;
    
    %Calculate rise and rise time
    Rise_Time(ii) = time(open_ind) - time(closed_ind);      %Time to open
    Rise(ii) = Position_f(open_ind,ii) - Position_f(closed_ind,ii);           %Difference in Voltage
    %Rise(ii) = data(open_ind) - data(closed_ind);           %Difference in Voltage
end;

%To pass, lets say both Rise_Time and Rise must be within 
%1 sigma of median.  Why median? This is not normally distributed.
%Look at data, and you will notice that all error is in one direction.
%I think median makes more sense here
% Median_Rise_Time = median(Rise_Time);
% Std_Rise_Time = std(Rise_Time);
% Median_Rise = median(Rise);
% Std_Rise = std(Rise);
% 
% %Failure analysis.  Look separately at which tests failed 
% % Rise_Time and which tests failed Rise.  Any tests failing
% % either fail.
% %These tests failed
% Fail_Rise_Time = find(abs(Rise_Time-Median_Rise_Time)>Std_Rise_Time);
% Fail_Rise = find(abs(Rise-Median_Rise)>Std_Rise);
% 
% Fail = union(Fail_Rise_Time,Fail_Rise);
% 
% %That must mean all of the rest passed!
% Pass_Rise_Time = setdiff(1:NTests,Fail_Rise_Time);
% Pass_Rise = setdiff(1:NTests,Fail_Rise);
% 
% Pass = setdiff(1:NTests,Fail);

%ALT: This forces failure.  Instead, pick a fixed percentage.  
Tolerance = .05;        %Tolerance from median value (Tolerance*100%)
Median_Rise_Time = median(Rise_Time);
Median_Rise = median(Rise);

%Failure analysis.  Look separately at which tests failed 
% Rise_Time and which tests failed Rise.  Any tests failing
% either fail.
%These tests failed
Fail_Rise_Time = find(abs(Rise_Time-Median_Rise_Time)>Tolerance*Median_Rise_Time);
Fail_Rise = find(abs(Rise-Median_Rise)>Tolerance*Median_Rise);

Fail = union(Fail_Rise_Time,Fail_Rise);

%That must mean all of the rest passed!
Pass_Rise_Time = setdiff(1:NTests,Fail_Rise_Time);
Pass_Rise = setdiff(1:NTests,Fail_Rise);

Pass = setdiff(1:NTests,Fail);

%Average the tests that passed.  This can further reduce noise
Position_f_Avg_Open = mean(Position_f(:,Pass_Rise_Time),2);
Position_f_Avg_Rise = mean(Position_f(:,Pass_Rise),2);
Position_f_Avg = mean(Position_f(:,Pass),2);        
Position_Avg = mean(Position(:,Pass),2);        

%Set up data for plotting.  I want to have MATLAB give me
% one handle per data point (instead of one handle for a line
% of data points).  This will allow me to define each point to
% have it's own callback.  What's the approach?
%  - MATLAB will give me one handle per line
%  - BUT, I'm only really plotting two lines
%     (one of good points, one of bad points)
%  - SO, I plot each point as a pair: [good point; NaN]. 
% explanation ...
%If I plotted just 3 vectors of data, MATLAB would create only a single
% graphics object, which could have only one callback.  What I want to do is to
% plot each data point as a separate line, so I can control the properties
% individually.  My trick is to add a column of NaN's (they don't appear
% on plots), and to transpose the vectors. 
%Consider a simple example with a 4 element vector.
% Before:                      After:
%   x = [1                     x = [1    2   3   4
%        2                          NaN NaN NaN NaN]
%        3
%        4]
%When I try to plot x, MATLAB will plot 4 lines.  The first point
% of each line will be the desired data point; the second will
% be a NaN.  Since NaN's don't plot, I'm in business!

%Trick MATLAB into giving me one handle per dot.

NFail_RT = length(Fail_Rise_Time);      %Rise time condition
NPass_RT = length(Pass_Rise_Time);
NFail_R = length(Fail_Rise);            %Rise angle condition
NPass_R = length(Pass_Rise);

%Expand with NaNs (see above)
Fail_RT_X = [Fail_Rise_Time;NaN*ones(1,NFail_RT)];      %RT - Rise Time
Fail_RT_Y = [Rise_Time(Fail_Rise_Time);NaN*ones(1,NFail_RT)];
Pass_RT_X = [Pass_Rise_Time;NaN*ones(1,NPass_RT)];
Pass_RT_Y = [Rise_Time(Pass_Rise_Time);NaN*ones(1,NPass_RT)];

Fail_R_X = [Fail_Rise;NaN*ones(1,NFail_R)];             %R - Rise (Angle)
Fail_R_Y = [Rise(Fail_Rise);NaN*ones(1,NFail_R)];
Pass_R_X = [Pass_Rise;NaN*ones(1,NPass_R)];
Pass_R_Y = [Rise(Pass_Rise);NaN*ones(1,NPass_R)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%   Figure 1:  Pass/Fail Statistics           %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Generate figure 1
% Top plot: Rise Time vs. Run Number
% Bottom plot: Rise Angle vs. Run Number
f1 = figure('Tag','Pass Fail Statistics');          %Tag is used by report generator
subplot(211);
pass_rt_h = plot(Pass_RT_X,Pass_RT_Y,'r.');         %Plot good values as red dots
hold on
fail_rt_h = plot(Fail_RT_X,Fail_RT_Y,'ko','MarkerFaceColor','k', ...
    'MarkerSize',4);                                %Plot the bad values as black dots
plot([1 NTests],Median_Rise_Time*[1 1], 'r', ...    %Show Statistics (median, 5% error)
    [1 NTests],Median_Rise_Time*(1+Tolerance*[1 -1;1 -1]),'r:','HitTest','off');

xlabel('Run Number');
ylabel('Rise Time (s)');
title('Test Results');
if isempty(Fail)
    legend(pass_rt_h(1),'All Tests Passed',2);
else
    legend([pass_rt_h(1) fail_rt_h(1)],'Pass','Fail',2);
end;

%We will add a context menu to highlight the curve in the next
% figure.  I need to create the figure first.

subplot(212);
pass_r_h = plot(Pass_R_X,Pass_R_Y,'r.');        %Plot good values
xlabel('Run Number');
ylabel('Rise Angle (deg)');
hold on
fail_r_h = plot(Fail_R_X,Fail_R_Y,'ko','MarkerFaceColor','k', ...
    'MarkerSize',4);        %Adds the black dots at bad values
plot([1 NTests],Median_Rise*[1 1], 'r', ...         %Statistics
    [1 NTests],Median_Rise*(1+Tolerance*[1 -1;1 -1]),'r:','HitTest','off');
if isempty(Fail)
    legend(pass_r_h(1),'All Tests Passed',3);
else
    legend([pass_r_h(1) fail_r_h(1)],'Pass','Fail',3);
end;

if ~genReport
    datalabel('on','ro')
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%   Figure 2:  Pass/Fail Time Series          %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Show signals for failures and passes
figure('Tag','All Tests (Pass/Fail)');
subplot(211);       %All failed tests.  Overlay Average test.

if isempty(Fail)
    th = text(.5,.5,'All Tests Passed', ...
        'HorizontalAlignment','Center', ...
        'FontSize',16,'FontWeight','Bold');
    axis on
    set(gca,'XTick',[],'YTick',[],'XColor',[1 1 1],'YColor',[1 1 1])
    fail_lh=[];
else
    fail_lh = plot(time,Position_f_Avg,'k-',time,Position_f(:,Fail));
    set(fail_lh(1),'LineWidth',2)
    title('Failed');
    ylabel('Angle (deg)');
    legend('Benchmark',4);
    linelabel(fail_lh(2:end),Fail);
end;

subplot(212);
pass_lh = plot(time,Position_f(:,Pass));
title('Passed');
xlabel('Time (s)');
ylabel('Angle (deg)');
linelabel(pass_lh,Pass);

%Show the run number when clicked on
%(Not implemented yet)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%   Final housecleaning.                     %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Merge handles into one vector, sorted by run number
clear handles
handles(Pass') = pass_lh;
handles(Fail') = fail_lh(2:end);        %First line is the benchmark.  skip it.

%Create context menu to bring up separate plot
mh = uicontextmenu('Callback','highlight_curve(gco,handles)','Parent',f1);
set([pass_rt_h;fail_rt_h;pass_r_h;fail_r_h],'UIContextMenu',mh);

figure(f1);     %Bring this figure to the front