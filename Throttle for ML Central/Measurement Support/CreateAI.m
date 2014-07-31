function ai = CreateAI(filename,vendor,boardid,channels);
%CreateAI          Create ai object for throttle demo.  Configures trigger
%
%  ai = CreateAI(filename,vendor,boardid,channels);

% Copyright 2002 - 2003 The MathWorks, Inc

if nargin==1
    vendor       = 'mcc';
    hw = daqhwinfo(vendor);
    boardid_index = find(strncmp('PC-CARD-DAS16',hw.BoardNames,13));
    if isempty(boardid_index)
        error('I''m sorry, but I can''t find your board.  Please use long form: CreateAI(filename,vendor,boardid,channels)');
    end;

    boardid = str2num(hw.InstalledBoardIds{boardid_index});
    channels     = 0;
end;

ai = analoginput(vendor,boardid);
addchannel(ai,channels);

ai.tag  = 'Valve';

TriggerDelay = -.25;
TriggerValue = 3;
TriggerCondition = 'Rising';

ConfigureTrigger(ai,TriggerDelay,TriggerValue,TriggerCondition);

if nargin>0 & ~isempty(filename);
    ai.LoggingMode = 'Disk&Memory';
    ai.LogFileName = filename;
    ai.LogToDiskMode = 'Overwrite';
end;
