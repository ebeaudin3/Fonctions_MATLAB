function [t_c,p_c] = find_transition(position,time)
%find_transition       Find the transition points
%
%  [t_c,p_c] = find_transition(position,time)
%
%Input
%  position        Position data.  Column vector
%  time            Time vector, same length as position
%
%Output
%  t_c   [2 x 1]   Time of the 2 critical points for transition
%  p_c   [2 x 1]   Position of the 2 critical points for transition

% Copyright 2002 - 2003 The MathWorks, Inc

%Find peaks and valleys
[pind,peaks] = findpeaks(position);        %findpeaks is extracted from fdutil, from sptool
[vind,valleys] = findpeaks(-position);       
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
rise = position(end_ind) - position(begin_ind);           %Difference in Voltage

t_c=[time(begin_ind);time(end_ind)];
p_c=[valleys(min_ind);peaks(max_ind+1)];
