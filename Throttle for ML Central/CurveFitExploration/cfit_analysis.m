if ~exist('Data','var')
    load ValveBatchTest_Relaxed
    VpDeg = 4.5 / 90;               %Volts per degree
    Position = Data / VpDeg;
end;
%cfit_analysis
% Analysis designed with curve fitting

%Apply to all data sets.
[Npts, NTests] = size(Data);
Slope_cfit = zeros(NTests,1);
makeplot = 0;           %Tell cfit routine to not plot
h = waitbar(0,'Please wait, I''m working really hard here ...');

for ii=1:NTests
    Slope_cfit(ii) = throttle_cfit(time,Position(:,ii),makeplot);
    waitbar(ii/NTests,h)
end;
close(h)


%Use the same analysis we used with the other test
%ALT: This forces failure.  Instead, pick a fixed percentage.  
Tolerance = .05;        %Tolerance from median value (Tolerance*100%)
Median_Slope = median(Slope_cfit);

%Failure analysis.  Look separately at which tests failed 
% Rise_Time and which tests failed Rise.  Any tests failing
% either fail.
%These tests failed
Fail_cfit = find(abs(Slope_cfit - Median_Slope)>Tolerance*Median_Slope);

Pass_cfit = setdiff(1:NTests,Fail);

Position_avg = mean(Position(:,Pass),2);


%Compare results with the other algorithm
%First, compute slope from other algorithm:
Slope = Rise./Rise_Time;
%Normalize
NSlope = Slope/median(Slope);
NSlope_cfit = Slope_cfit/median(Slope_cfit);


figure('Tag','Curve Fit Pass/Fail');
ph = plot(1:NTests,NSlope,'r.',1:NTests,NSlope_cfit,'b.');
set(ph,'MarkerSize',14);
xlabel('Run Number');
ylabel('Normalized Slope');
title('Algorithm Comparison');
hold on
plot(Fail,NSlope(Fail),'ko','MarkerFaceColor','k', ...
    'MarkerEdgeColor','r','MarkerSize',5);
plot(Fail_cfit,NSlope_cfit(Fail_cfit),'ko','MarkerFaceColor','k', ...
    'MarkerEdgeColor','b','MarkerSize',5);
plot([1 NTests],[1 1], 'r', ...            %Stats
    [1 NTests],(1+Tolerance*[1 -1;1 -1]),'r:');
legend('Original Algorithm Pass','Curve Fit Algorithm Pass', ...
    'Original Algorithm Fail','Curve Fit Algorithm Fail',3);
datalabel('on','go')


% %Show signals for failures and passes
% figure('Tag','All Tests (Pass/Fail)');
% subplot(211);       %All failed tests.  Overlay Average test.
% 
% if isempty(Fail)
%     th = text(.5,.5,'All Tests Passed', ...
%         'HorizontalAlignment','Center', ...
%         'FontSize',16,'FontWeight','Bold');
%     axis on
%     set(gca,'XTick',[],'YTick',[],'XColor',[1 1 1],'YColor',[1 1 1])
% else
%     lh = plot(time,Position_avg,'k-',time,Position(:,Fail));
%     set(lh(1),'LineWidth',2)
%     title('Failed');
%     ylabel('Angle (deg)');
%     legend('Benchmark',4);
% end;
% 
% 
% subplot(212);
% plot(time,Position(:,Pass))
% title('Passed');
% xlabel('Time (s)');
% ylabel('Angle (deg)');
% axis([-0.3000    0.5000   20.0000  100.0000]);
