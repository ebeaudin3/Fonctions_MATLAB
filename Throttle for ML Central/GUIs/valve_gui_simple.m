function varargout = valve_gui_simple(varargin)
% valve_gui_simple    GUI to open, close, and relax the throttle
% Scott Hirsch
% shirsch@mathworks.com

% VALVE_GUI_SIMPLE Application M-file for valve_gui_simple.fig
%    FIG = VALVE_GUI_SIMPLE launch valve_gui_simple GUI.
%    VALVE_GUI_SIMPLE('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 08-May-2002 11:31:42
% Copyright 2002 - 2003 The MathWorks, Inc

if nargin == 0  % LAUNCH GUI
    
    %Create digitalio object
    dio = CreateDIO;
    
    fig = openfig(mfilename,'reuse');
    
    % Use system color scheme for figure:
    set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));
    
    % Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);
    handles.dio = dio;
    guidata(fig, handles);
    


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

delete(handles.dio);
delete(handles.figure1);
