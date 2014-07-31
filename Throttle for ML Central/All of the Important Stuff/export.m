function export(filename,time,position);
%export      Create an Excel spreadsheet from recorded time and position
%
%  export(filename,time,position)
%Inputs
%  filename     String specifying exported filename (no extension)
%  time         Vector of time values
%  position     Vector of position values
%
% time and position must be the same length

% Copyright 2002 - 2003 The MathWorks, Inc

time = time(:);
position = position(:);

colnames = {'time','position'};

xlswrite(filename,[time position],colnames);

%Open the file
try
    dos([filename '.xls']);
end;