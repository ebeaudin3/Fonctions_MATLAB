function dio = CreateDIO(vendor,boardid,channels);
%CreateDIO        Create and configure dio object for throttle demo
%
% dio = CreateDIO(vendor,boardid,channels);
% dio = CreateDIO looks for the Computer Boards PC-CARD-DAS16

% Copyright 2002 - 2003 The MathWorks, Inc

try
if nargin==0
    vendor       = 'mcc';
    hw = daqhwinfo(vendor);
    boardid_index = find(strncmp('PC-CARD-DAS16',hw.BoardNames,13));
    if isempty(boardid_index)
        error('I''m sorry, but I can''t find your board.  Please use long form: CreateDIO(vendor,boardid,channels)');
    end;

    boardid = str2num(hw.InstalledBoardIds{boardid_index});
    channels     = 0:1;
end;

dio = digitalio(vendor,boardid);
addline(dio,channels,0,'Out');
dio.tag = 'Valve';

catch
    error('I couldn''t create the DIO Object.  Specify your hardware info in the call to CreateDIO.');
end;
