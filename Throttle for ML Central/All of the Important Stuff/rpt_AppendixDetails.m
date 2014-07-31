%Batch calculation of peaks and valleys.  Use in appendix
% [Pind,Peaks] = findpeaks(Position_f);        %One long vector
% [Vind,Valleys] = findpeaks(-Position_f);     
% Valleys = -Valleys;
% Pind = rem(Pind,NSamples);Pind(Pind==0)=NSamples;
% Vind = rem(Vind,NSamples);Vind(Vind==0)=NSamples;
% plot(time,Position_f,time(Pind),Peaks,'^',time(Vind),Valleys,'v')

Npp = 3;        %Number of plots per page
%figind=0;
new_figure = 1;
%ind = 0;
for ii=1:NTests %[Pass Fail]
    %ind = ind+1;
    if new_figure
        figure('Tag','Appendix');
    end;
    
    plotind = rem(ii,Npp);
    if plotind==0       %Last plot on this figure
        plotind=Npp; 
        new_figure = 1;     %New figure next time around
    else
        new_figure = 0;
    end;
    
    if ismember(ii,Pass)
        str = 'Pass';
    else
        str = 'Fail';
    end;
    
    subplot(3,1,plotind);
    ph = plot(time,Position_f(:,ii),time(Pind{ii}),Peaks{ii},'^',time(Vind{ii}),Valleys{ii},'v');
    set(ph,'MarkerSize',5);
    title(['Run #' num2str(ii) ' (' str ')'])
    ylabel('Angle (deg)');
    axis([min(time) max(time) 20 90]);
    
    if new_figure
        xlabel('Time (s)');
    else
        set(gca,'XTickLabel','');
    end;
    
    %Color transition peaks
    hold on;
    ph = plot(time(Begin_ind(ii)),Position_f(Begin_ind(ii),ii),'rv',time(End_ind(ii)),Position_f(End_ind(ii),ii),'g^');
    set(ph,'MarkerFaceColor','k')
    
end;

%Catch last figure
xlabel('Time (s)');
xt = get(gca,'XTick');
xt(abs(xt)<eps)=0;
set(gca,'XTickLabel',xt);

