function [matrix] = vector2matrix365(vector)

% Convert vector structures [Datesx1] to matrix structures [366daysxYears]
%
% Input :   Daily data matrix with days in one column
%           All years must have 365 days
%
% Output :  Daily data in matrix
%           Matrix line : Days (from 1 to 366, if the current year is a
%           non-leap year, the last day is NaN)
%           Matrix column : Years
%
% By : Pascale
% Modified by : ?lise Beaudin
% Last modification : May 15, 2014

% Verification : all years must have 365 days
    if mod(length(vector),365)~=0
        disp('!!! Error : All years must have 365 days')
    end

% Define NaN matrix (to fit leap years)
    %matrix = NaN(366,length(vector)/366);
    
    startDay = 1;
    endDay = 365;
    
for year = 1:length(vector)/365
    matrix(:,year) = vector(startDay:endDay);
    startDay = endDay+1;
    endDay = endDay+365;
end