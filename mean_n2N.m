function [meanvect] = mean_n2N(matrix,firstcol,lastcol)

% Calculates the mean of each row of column n (firstcol) to column N
% (lastcol) of a matrix.
%
% Input :   Data matrix
%           Number of the first and last column evaluated
%
% Output :  Column vector containing the mean of each row
%
% By : Elise Beaudin
% Last modification : May 16, 2014

% Verification : column numbers are real
if isreal(firstcol)==0
    disp('!!! Error : You have to enter only real numbers')
end
if isreal(lastcol)==0
    disp('!!! Error : You have to enter only real numbers')
end


% Reshaping the matrix keeping columns from firstcol to lastcol
new_matrix = matrix(:,[firstcol:lastcol]) ;

%calcultate the mean of each row over the new matrix
meanvect = mean(new_matrix,2) ;
    
    
    