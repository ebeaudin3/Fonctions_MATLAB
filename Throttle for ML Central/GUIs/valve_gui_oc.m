function varargout = valve_gui_oc(varargin)
%valve_gui_oc       A GUI to control the throttle and view it's response

% VALVE_GUI_OC Application M-file for valve_gui_oc.fig
%    FIG = VALVE_GUI_OC launch valve_gui_oc GUI.
%    VALVE_GUI_OC('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 08-May-2002 11:21:29
% Copyright 2002 - 2003 The MathWorks, Inc

if nargin == 0  % LAUNCH GUI
    fig = openfig(mfilename,'reuse');
    % Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);

    %Initialization:
    % - Hardware (ai, dio)
    % - Load Filter
    % - Graphics
    
    %Look for these dio and ai objects
    d = daqfind('Tag','Valve');
    for ii=1:length(d)
        stop(d{ii});
        delete(d{ii});
    end;
    
    %Configure hardware
    ai = CreateAI([]);
    dio = CreateDIO;
    
    TriggerDelay = -.25;
    TriggerRange = [2.9 3.1];     %In degrees
    ConfigureTrigger(ai,TriggerDelay,TriggerRange,'Leaving');
    
    %Load pre-designed filter
    try
        load valve_sptool_export
    catch
        [filename,pathname] = uigetfile('valve_sptool_export.mat', ...
            'Please locate valve_sptool_export.mat');
        load([pathname filename]);
    end;
    
    
    
    % Use system color scheme for figure:
    set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));
    
    
    %Initialize graphics
    Ns = ai.SamplesPerTrigger;
    dt = 1 / ai.SampleRate;
    t =(0:1:Ns-1)*dt;
    
    %Two lines: open and close response
    axes(handles.OpenAxes);
    lh = plot(t,zeros(length(t),2),'Tag','ResponseLines');        %lh - line handles
    xlabel('Time (s)');
    ylabel(['Angle (deg)']);
    title('Valve response');
    axis([0 Ns*dt 0 90]);
    
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
        'Visible','Off', ...
        'Tag','RiseTimeText');
    
    %Label rise
    lh = line([0;0],[0;1],'Color','k','LineStyle','-.','Visible','off','Tag','RiseLine');
    th = text(0,.5,{'Rise: '; [num2str(0) ' \circ']}, ...
        'HorizontalAlignment','Center', ...
        'FontWeight','Bold', ...
        'Visible','Off', ...
        'Tag','RiseText');
    
    legend('Open Response','Close Response');
    
    %Get with updated graphics
    handles = guihandles(fig);

    %Add custom fields
    handles.ai = ai;
    handles.dio = dio;
    handles.filter = filt1.tf;      %Filter
    handles.lh = lh;                %Handle to reponse lines            
    handles.mh = mh;                %Handles to critical point markers
    handles.visible = 0;
    
    guidata(fig, handles);
    
    
    %Configure object to plot data after acquiring one trigger of data
    ai.SamplesAcquiredFcnCount = ai.SamplesPerTrigger;
    ai.SamplesAcquiredFcn = {@localPlotData, handles};
    start(ai)    
    
    
    if nargout > 0
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


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = Open_Callback(h, eventdata, handles, varargin)
putvalue(handles.dio,[1 0]);

% --------------------------------------------------------------------
function varargout = Close_Callback(h, eventdata, handles, varargin)
putvalue(handles.dio,[0 1]);

% --------------------------------------------------------------------
function varargout = Relax_Callback(h, eventdata, handles, varargin)
putvalue(handles.dio,[0 0]);

% --------------------------------------------------------------------
function varargout = figure1_CloseRequestFcn(h, eventdata, handles, varargin)
stop(handles.ai);
delete([handles.ai handles.dio]);
delete(handles.figure1);


% --------------------------------------------------------------------
function localPlotData(ai,event,handles);
[d,time] = getdata(ai,ai.SamplesAvailable);

VpDeg = 4.5 / 90;               %Volts per degree
position = d / VpDeg;        %data in degree

time = time - time(1);      %Remove offset
%Figure out if this was opening or closing
%Look at digital line
out = getvalue(handles.dio.Line(1:2));

if out(1) & ~out(2)   %Open
    set(handles.ResponseLines(2),'YData',position);
elseif out(2) & ~out(1)
    set(handles.ResponseLines(1),'YData',position);
else    %Relax condition
    %Don't do anything
end;

if out(1) & ~out(2)   %Open
    
    %If open, apply algorithm
    df = filtfilt(handles.filter.num,handles.filter.den,position); %Filter
    
    [t_c, d_c] = find_transition(df,time);
    
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

% --------------------------------------------------------------------
function varargout = FileMenu_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = SaveMenu_Callback(h, eventdata, handles, varargin)
l = get(handles.OpenAxes,'Children');
data = get(l,'YData');
time = get(l(1),'XData');

open_data = data{1};
close_data = data{2};

[filename,pathname] = uiputfile('*.mat','Save data as');
save([pathname filename],'open_data','close_data','time');



function [t_c,p_c] = find_transition(position,time)
%find_transition       Find the transition points
%Input
%  position        Position data.  Column vector
%  time            Time vector, same length as position
%
%Output
%  t_c   [1 x 2]   Time of the 2 critical points for transition
%  p_c   [1 x 2]   Position of the 2 critical points for transition

%Find peaks and valleys
[pind,peaks] = findpeaks(position);        %findpeaks is extracted from fdutil, from sptool
[vind,valleys] = findpeaks(-position);       
valleys = -valleys;

%Find valley before rise, peak after rise
[junk,max_ind] = max(diff(peaks));
[junk,min_ind] = max(diff(valleys));

begin_ind = vind(min_ind);          %Index to last valley before open.  This indexes the original time series
end_ind = pind(max_ind+1);          %Index to first peak after open

%Calculate rise and rise time
rise_time = time(end_ind) - time(begin_ind);      %Time to open
rise = position(end_ind) - position(begin_ind);           %Difference in Voltage

t_c=[time(begin_ind);time(end_ind)];
p_c=[valleys(min_ind);peaks(max_ind+1)];



