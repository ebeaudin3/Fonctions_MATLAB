function [matrix]=vector2matrix_p(vector)

% Convert vector structures [Daysx1] to matrix structures [366daysxYears]
%
% Input :   Daily data matrix with days in one column
%           All years mus have 366 days
%           A non-leap year must shows NaN or 0 on the 366th day 
%
% Output :  Daily data in matrix
%           Matrix line : Days (from 1 to 366, if the current year is not a
%           leap year, the last day is NaN)
%           Matrix column : Years
%
% By : Pascale Girard
% Last modification : 12 mai 2014

%   Verification : all years must have 366 days
    if mod(length(vector),366)~=0
        disp('??? All years must have 366 days')
    end
  
%   Define NaN matrix (to fit leap years)
    matrix=NaN(366,length(vector)/366);
    
    startDay=1;
    endDay=366;

for year=1:length(vector)/366
	matrix(:,year)=vector(startDay:endDay);
    startDay=endDay+1;
    endDay=endDay+366;

end