function show_data(h);
%Input:
%  h      Handle to the line being plotted

% Copyright 2002 - 2003 The MathWorks, Inc

Position_f = evalin('base','Position_f');
time = evalin('base','time');

plot_index = get(h,'UserData');


%Find the figure.  Create if necessary
fh = findobj('Type','Figure','Tag','ShowDataFigure');
if isempty(fh)
    figure('Tag','ShowDataFigure');
    figshift;       %Offset from other windows
else
    set(0,'CurrentFigure',fh);      %Make current figure
end;

plot(time,Position_f(:,plot_index));
title(['Run Number ' num2str(plot_index)]);
xlabel('Time (s)');
ylabel('Angle (deg)');