function [extvect] = ext_n2N(matrix,extremum,firstcol,lastcol)

% Find the max or min values of each row over column n to N.
%
% Input :   Data matrix
%           Extremum (enter max=1 or min=2)
%           Number of the first and last column evaluated
%
% Output :  Column vector containing the max or min of each row
%
% By : Elise Beaudin
% Last modification : May 20, 2014

% Verification : column numbers are real
if isreal(firstcol)==0
    disp('!!! Error : You have to enter only real numbers')
end
if isreal(lastcol)==0
    disp('!!! Error : You have to enter only real numbers')
end


% Reshaping the matrix keeping columns from firstcol to lastcol
new_matrix = matrix(:,[firstcol:lastcol]) ;

%find the max or min of each row over the new matrix
if extremum==1
    extvect = max(new_matrix,[],2) ;
elseif extremum==2
    extvect = min(new_matrix,[],2) ;
end
