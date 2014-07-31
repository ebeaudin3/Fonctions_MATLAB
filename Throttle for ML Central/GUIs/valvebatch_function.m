function [ai,dio] = valvebatch_function(Nruns,filename,linehandle,SamplesPerTrigger,SampleRate);
%Run a whole bunch of tests of the valve

% Copyright 2002 - 2003 The MathWorks, Inc


%Handle input arguments
if nargin<1         %Number of runs
    Nruns=10;
end;

if nargin<2         %Log file name
    [filename,pathname] = uiputfile('*.daq','Save file as');
    filename = [pathname filename];
end;

if nargin<3         %Handle to existing response plot
    linehandle = [];
end;

if nargin<4
    SamplesPerTrigger = 750;
end;

if nargin<5
    SampleRate = 1000;
end;

%DIO Timer Configuration
TimerPeriod = SamplesPerTrigger / SampleRate;  
%Every timer event will toggle the state of the 
% throttle between open and relaxed

%Get rid of existing associated daq objects
d = daqfind('Tag','Valve');
for ii=1:length(d)
    stop(d{ii});
    delete(d{ii});
end;


%Configure hardware for ai and dio
%AI Trigger Configuration
TriggerDelay = -.25;
TriggerValue = 3;

%Create dio and ai objects
ai = CreateAI([]);
dio = CreateDIO;
ConfigureTrigger(ai,TriggerDelay,TriggerValue,'Rising');
ai.SamplesPerTrigger     = SamplesPerTrigger;
ai.SampleRate            = SampleRate;

%Store counter in ai
ai.UserData = [0 0];                       %[FlipNumber RunNumber]

%File Logging
ai.LoggingMode = 'Disk&Memory';
ai.LogFileName = filename;
ai.LogToDiskMode = 'Index';

%Initialize Graphics
if isempty(linehandle)
    fig = findobj('Tag','ValveFigure');
    if isempty(fig)
        fig = figure('Tag','ValveFigure');
        time = (0:1:ai.SamplesPerTrigger-1) / ai.SampleRate;
        lh = plot(time,zeros(size(time)),'Tag','ValveLine');
        xlabel('Time (s)');
        ylabel('Angle (deg)');
        title('Run Number: ');
    else
        lh = findobj('Tag','ValveLine');
    end;
else
    lh = linehandle;
end;
    
ai.StopFcn = {@local_AIStopFcn,dio,guidata(lh)};

%There are two primary callbacks:
% dio.TimerFcn.  This flips the valve open and closed at the specified interval.
% ai.SamplesAcquiredFcn  This grabs, analyzes, and plots available data

dio.TimerFcn = {@flipdio,Nruns,ai};    %Flips signal
dio.TimerPeriod = TimerPeriod;        %Flip twice for one cycle


ai.SamplesAcquiredFcn = {@display_data,lh};
ai.SamplesAcquiredFcnCount = ai.SamplesPerTrigger;


%putvalue(dio,[0 1]);        %Start closed
putvalue(dio,[0 0]);        %Start relaxed

start([ai dio]);


% -------------------------------
%DIO Timer Callback Function
function flipdio(dio,event,Nruns,ai);
%Count number of runs
UD = ai.UserData;
FlipNumber = UD(1);
RunNumber = UD(2);
FlipNumber = FlipNumber+1;       %Two flips per run

RunNumber = floor(FlipNumber/2);
ai.UserData = [FlipNumber RunNumber];


s = getvalue(dio);
putvalue(dio,[~s(1) s(2)])        %FLip first line only

if RunNumber==Nruns
    stop([dio ai]);
    putvalue(dio,[0 0]);
end;


%AI Trigger Callback Function
function display_data(ai,event,lh);

%Count number of runs
UD = ai.UserData;
FlipNumber = UD(1);
RunNumber = UD(2);

[d,t] = getdata(ai,ai.SamplesPerTrigger);

%Calibrate data
VpDeg = 4.5 / 90;               %Volts per degree
d = d / VpDeg;

set(lh,'YData',d);
title(['Run number: ' num2str(RunNumber+1)]);

handles = guidata(lh);


%When driven by the valve_gui_batch GUI, we also
% apply the transition detection algorithm
if isfield(handles,'filter');
    
    position = filtfilt(handles.filter.num,handles.filter.den,d); %Filter
    time = t - t(1);        %Remove offset
    [t_c,d_c] = find_transition(position,time);
    
    %Update graphics
    rise = diff(d_c);
    rise_time = diff(t_c);
    
    set(handles.Markers(2),'XData',t_c(1),'YData',d_c(1));
    set(handles.Markers(1),'XData',t_c(2),'YData',d_c(2));
    
    set(handles.RiseTimeLine,'XData',t_c,'YData',d_c([1;1]));
    set(handles.RiseLine,'XData',t_c([1;1]),'YData',d_c);
    
    set(handles.RiseTimeText,'Position',[mean(t_c) d_c(1) 0], ...
        'String',{'Rise Time: '; [num2str(rise_time) ' s']});
    
    set(handles.RiseText,'Position',[t_c(1) mean(d_c) 0], ...
        'String',{'Rise: '; [num2str(rise) ' \circ']});
    
    if ~handles.visible
        set([handles.Markers ...
                handles.RiseTimeLine ...
                handles.RiseLine ...
                handles.RiseTimeText ...
                handles.RiseText],'Visible','on')
        
        
        handles.visible = 1;
    end;
end;



function local_AIStopFcn(ai,event,dio,handles);
putvalue(dio,[0 0]);

%When driven by the valve_gui_batch GUI, we should
% also reset the states of the Run/Stop buttons
if isfield(handles,'Stop');
    set(handles.Stop,'Enable','off');
    set(handles.Run,'Enable','on');
end;


%Generate report
CreateReport = get(handles.CreateReport,'Value');

if CreateReport
    filename = get(handles.FileName,'String');
    %filename = which(filename);     %Get full path
    [pathname,filename,ext] = fileparts(filename);
    genReport = 1;
    
    %Strip extension
    assignin('base','filename',filename);       %Name of .daq file; Used by report
    assignin('base','genReport',genReport);     %Tells analysis script that we are making a report
    report Valve_Analysis
end;

