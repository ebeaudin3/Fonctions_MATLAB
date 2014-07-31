function highlight_curve(h,lh);
%Input
%  h       gco
%  lh      Handle to lines to highlight

% Copyright 2002 - 2003 The MathWorks, Inc

%If any lines on this axis are selected, deselect them.
sel = findobj(get(get(lh(1),'Parent'),'Parent'),'Selected','on');
set(sel,'Selected','off');

ud = get(h,'XData');
ud = ud(1)  %Get rid of NaN
set(lh(ud),'Selected','on')

