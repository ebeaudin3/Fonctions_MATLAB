function i2_month_format = scen_calendar_month(i1_year,s_calendar)

% Numbers of days per month of the year in a calendar
%
% Inputs:
%     1. Year(s) (Nx1 vector)
%     2. Calendar (string)
%
% Ouputs:
%     1. Nx12 list of days per month
%
% Details:
%     -- Supported calendars are: gregorian, standard, proleptic_gregorian,
%         noleap, 365_day, all_leap, 366_day, 360_day, julian.


% definition of i2_days_in_month(:,:)
% i2_days_in_month(1,:) - regular year
% i2_days_in_month(2,:) - divisible by 4, but not by 100, unless also by 400
% i2_days_in_month(3,:) - divisible by 100 after October 15 1582
% i2_days_in_month(4,:) - divisible by 100 before October 15 1582
% i2_days_in_month(5,:) - year 1582

flag_gregorian_skip = 0;

% Gregorian calendar
if strcmp('gregorian',s_calendar) | strcmp('standard',s_calendar)
    i2_days_in_month = [...
    31 28 31 30 31 30 31 31 30 31 30 31;...
    31 29 31 30 31 30 31 31 30 31 30 31;...
    31 28 31 30 31 30 31 31 30 31 30 31;...
    31 29 31 30 31 30 31 31 30 31 30 31;...
    31 28 31 30 31 30 31 31 30 21 30 31];
    flag_gregorian_skip = 1;

% Proleptic-gregorian calendar
elseif strcmp('proleptic_gregorian',s_calendar)
    i2_days_in_month = [...
    31 28 31 30 31 30 31 31 30 31 30 31;...
    31 29 31 30 31 30 31 31 30 31 30 31;...
    31 28 31 30 31 30 31 31 30 31 30 31;...
    31 28 31 30 31 30 31 31 30 31 30 31;...
    31 28 31 30 31 30 31 31 30 31 30 31];

% 365-days calendar
elseif strcmp('noleap',s_calendar) | strcmp('365_day',s_calendar)
    i2_days_in_month = [...
    31 28 31 30 31 30 31 31 30 31 30 31;...
    31 28 31 30 31 30 31 31 30 31 30 31;...
    31 28 31 30 31 30 31 31 30 31 30 31;...
    31 28 31 30 31 30 31 31 30 31 30 31;...
    31 28 31 30 31 30 31 31 30 31 30 31];

% 366-days calendar
elseif strcmp('all_leap',s_calendar) | strcmp('366_day',s_calendar)
    i2_days_in_month = [...
    31 29 31 30 31 30 31 31 30 31 30 31;...
    31 29 31 30 31 30 31 31 30 31 30 31;...
    31 29 31 30 31 30 31 31 30 31 30 31;...
    31 29 31 30 31 30 31 31 30 31 30 31;...
    31 29 31 30 31 30 31 31 30 31 30 31];

% 360-days calendar
elseif strcmp('360_day',s_calendar)
    i2_days_in_month = [...
    30 30 30 30 30 30 30 30 30 30 30 30;...
    30 30 30 30 30 30 30 30 30 30 30 30;...
    30 30 30 30 30 30 30 30 30 30 30 30;...
    30 30 30 30 30 30 30 30 30 30 30 30;...
    30 30 30 30 30 30 30 30 30 30 30 30];

% Julian calendar
elseif strcmp('julian',s_calendar)
    i2_days_in_month = [...
    31 28 31 30 31 30 31 31 30 31 30 31;...
    31 29 31 30 31 30 31 31 30 31 30 31;...
    31 29 31 30 31 30 31 31 30 31 30 31;...
    31 29 31 30 31 30 31 31 30 31 30 31;...
    31 29 31 30 31 30 31 31 30 31 30 31];
end



flag_id(:,2) = ((mod(i1_year,4) == 0) & ...
((mod(i1_year,100) ~= 0) | (mod(i1_year,400) == 0)));
flag_id(:,3) = ((mod(i1_year,100) == 0) & (i1_year > 1582) & ...
(flag_id(:,2) == 0));
flag_id(:,4) = ((mod(i1_year,100) == 0) & (i1_year < 1582) & ...
(sum(flag_id(:,2:3),2) == 0));
flag_id(:,5) = ((i1_year == 1582) & (flag_gregorian_skip == 1));
flag_id(:,1) = (sum(flag_id(:,2:5),2) == 0);
i2_month_format = flag_id*i2_days_in_month;