function varargout = valve_gui_batch(varargin)
% VALVE_GUI_BATCH Integrated Measurement System Application
%
%

% Scott Hirsch
% shirsch@mathworks.com
% Copyright 2002 - 2003 The MathWorks, Inc

%Program Notes:
%This file handles little more than the GUI.  Everything that happens
% when you press one (the automated test and analysis) is all performed
% by valvebatch_function.  This means that all data acquisition object
% creation and references are in valvebatch_function

% Last Modified by GUIDE v2.0 15-May-2002 08:02:40

if nargin == 0  % LAUNCH GUI
    
    
    fig = openfig(mfilename,'reuse');
    % Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);
    % Use system color scheme for figure:
    set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

    %Initialization
    % - Delete existing daq objects
    % - Load filter
    % - Initialize Graphics Display
    
    %Look for these dio and ai objects
    d = daqfind('Tag','Valve');
    for ii=1:length(d)
        stop(d{ii});
        delete(d{ii});
    end;
    
    
    
    %Load pre-designed filter
    try
        %Look in the workspace for filt1.  If we can't find it, try to load
        %  the saved filter
        if evalin('base','~exist(''filt1'',''var'')');                        %From sptool
            load valve_sptool_export
        end;
        %Extract data:
        num = filt1.tf.num;
        den = filt1.tf.den;
        
    catch
        [filename,pathname] = uigetfile('valve_sptool_export.mat', ...
            'Please locate valve_sptool_export.mat (In Data Files)');
        load([pathname filename]);
    end;
    
    %Initialize graphics.  We need to know about the data we'll be receiving,
    % so I set up the trigger parameters here
    SamplesPerTrigger = 750;
    SampleRate = 1000;
    dt = 1/SampleRate;
    t =(0:1:SamplesPerTrigger-1)*dt;
    
    %Open response
    axes(handles.OpenAxes);
    lh = plot(t,zeros(length(t),1), ...
        'Tag','ResponseLine', ...
        'UserData',0);        %lh - line handle; UserData = RunNumber
    xlabel('Time (s)');
    ylabel(['Angles (deg)']);
    title('Run Number: 0');
    axis([0 SamplesPerTrigger*dt 0 90]);
    
    %Re-Tag Axes
    set(gca,'Tag','OpenAxes');
    
    %Markers: transition points for open and close
    hold on
    mh = plot(0,0,'rv',0,0,'g^','Visible','off','Tag','Markers');
    set(mh,'MarkerFaceColor','k')
    hold off
    
    
    %Label rise time
    lh = line([0;1],[0;0],'Color','k','LineStyle','-.','Visible','off','Tag','RiseTimeLine');
    th = text(.5,0,{'Rise Time: '; [num2str(0) ' s']}, ...
        'HorizontalAlignment','Center', ...
        'VerticalAlignment','Bottom', ...
        'FontWeight','Bold', ...
        'Visible','Off','Tag','RiseTimeText');
    
    %Label rise
    lh = line([0;0],[0;1],'Color','k','LineStyle','-.','Visible','off','Tag','RiseLine');
    th = text(0,.5,{'Rise: '; [num2str(0) ' \circ']}, ...
        'HorizontalAlignment','Center', ...
        'FontWeight','Bold', ...
        'Visible','Off','Tag','RiseText');
    
    %    legend('Open Response','Close Response');
    
    %Get with updated graphics
    handles = guihandles(fig);
    handles.ai=[];
    handles.dio=[];
    handles.filter = filt1.tf;      %Filter
    handles.visible = 0;            %Markers and such are initially invisible
    
    handles.SamplesPerTrigger = SamplesPerTrigger;                    %Number of samples per analog input trigger
    handles.SampleRate = SampleRate;    %Analog Input Sample Rate
    guidata(fig, handles);
    
    
    if nargout > 0f
        varargout{1} = fig;
    end
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    
    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch
        disp(lasterr);
    end
    
end


% --------------------------------------------------------------------
function varargout = Run_Callback(h, eventdata, handles, varargin)
filename = get(handles.FileName,'String');
Nruns = str2num(get(handles.NoRuns,'String'));

set(handles.Stop,'Enable','on');
set(handles.Run,'Enable','off');

[ai,dio] = valvebatch_function(Nruns,filename,handles.ResponseLine,handles.SamplesPerTrigger,handles.SampleRate);
handles.ai = ai;
handles.dio = dio;

guidata(handles.figure1,handles);




% --------------------------------------------------------------------
function varargout = Stop_Callback(h, eventdata, handles, varargin)
%Stop the daq objects
try 
    putvalue(handles.dio,[0 0]);        %Relax the throttle first
    stop([handles.dio handles.ai]);
catch
end;

set(handles.Run,'Enable','on');
set(handles.Stop,'Enable','off');

% --------------------------------------------------------------------
function varargout = figure1_CloseRequestFcn(h, eventdata, handles, varargin)
try 
    putvalue(handles.dio,[0 0]);
    stop(handles.ai);
    delete([handles.ai handles.dio]);
catch
end;

delete([handles.ai handles.dio]);
delete(handles.figure1);


% --------------------------------------------------------------------
function varargout = NoRuns_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
function varargout = FileName_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = Browse_Callback(h, eventdata, handles, varargin)

[filename,pathname] = uiputfile('*.daq','Save data as');
if filename~=0      %Only if user selected something
    
    %Force the extension to be .daq
    [junk,file,ext] = fileparts(filename);
    if isempty(ext) | ~strcmp(ext,'.daq')
        filename = [file '.daq'];
    end;
    
    set(handles.FileName,'String',[pathname filename]);
end;





% --------------------------------------------------------------------
function varargout = CreateReport_Callback(h, eventdata, handles, varargin)

