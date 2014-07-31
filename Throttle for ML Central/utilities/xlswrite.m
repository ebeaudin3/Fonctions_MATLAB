function xlswrite(filename,m,colnames);
% Write a simple, 2-column Excel file with column headers
%
%  xlswrite(filename,m,colnames);

% Scott Hirsch
% Copyright 2002 - 2003 The MathWorks, Inc


% Open Excel, add workbook, change active worksheet, 
% get/put array, save.
% First, open an Excel Server.
Excel = actxserver('Excel.Application');
%set(Excel, 'Visible', 1);
% Insert a new workbook.
Workbooks = Excel.Workbooks;
Workbook = invoke(Workbooks, 'Add');
% Make the first sheet active.
Sheets = Excel.ActiveWorkBook.Sheets;
sheet1 = get(Sheets, 'Item', 1);
invoke(sheet1, 'Activate');
% Get a handle to the active sheet.
Activesheet = Excel.Activesheet;

ActivesheetRange = get(Activesheet,'Range','A1','A1');
set(ActivesheetRange, 'Value', colnames{1});

ActivesheetRange = get(Activesheet,'Range','B1','B1');
set(ActivesheetRange, 'Value', colnames{2});

% Put a MATLAB array into Excel.
ActivesheetRange = get(Activesheet,'Range','A2','B751');
set(ActivesheetRange, 'Value', m);

% Now, save the workbook.
invoke(Workbook, 'SaveAs', [pwd filesep filename]);
invoke(Excel, 'Quit');

delete(Excel)