function varargout = getscopedata_gui(varargin)
% GETSCOPEDATA_GUI Application M-file for getscopedata_gui.fig
%    FIG = GETSCOPEDATA_GUI launch getscopedata_gui GUI.
%    GETSCOPEDATA_GUI('callback_name', ...) invoke the named callback.
%
% This simple example grabs data from channel 1 of a Tektronix TDS210
%   oscilloscope.
% To use:
%   - Select the COM port to which your scope is connected
%   - Press "Acquire Data"
%   - wait patiently ....


% Last Modified by GUIDE v2.5 31-Jan-2003 14:31:29
% Copyright 2002 - 2003 The MathWorks, Inc

if nargin == 0  % LAUNCH GUI
    
    fig = openfig(mfilename,'reuse');
    
    % Use system color scheme for figure:
    set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));
    
    
    % Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);

    set([handles.GPIBBoard handles.GPIBText handles.GPIBAddress],'Enable','off');
    
    
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
function varargout = SerialPortMenu_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = AcquireButton_Callback(h, eventdata, handles, varargin)

%Disable uicontrols
set(h,'Enable','off');
% set(handles.SerialPortMenu,'Enable','off');
% set(handles.GPIBBoard,'Enable','off');

%Establish communication
com = get(handles.ProtocolMenu,'Value');

if com==1   %Serial
    port = get(handles.SerialPortMenu,'Value');
    list = get(handles.SerialPortMenu,'String');
    port_name = list{port};
    s = instrfind('Type','serial','Tag','ScopeDataGUI','Status','Open');
    if isempty(s)
        s=serial(port_name,'Tag','ScopeDataGUI');
        s.InputBufferSize=2500*8;
        try 
            fopen(s);
        catch
            set([handles.SerialPortMenu h handles.GPIBVendor handles.GPIBAddress handles.GPIBBoard],'Enable','on');
            warndlg(lasterr)
        end;
        
    end;
else        %GPIB
    vendorstr = get(handles.GPIBVendor,'String');
    vendor = vendorstr{get(handles.GPIBVendor,'Value')};
    boardid = str2num(get(handles.GPIBBoard,'String'));
    address = str2num(get(handles.GPIBAddress,'String'));
    s = instrfind('Type','gpib','Tag','ScopeDataGUI','Status','Open');
    if isempty(s)
        s = gpib(vendor,boardid,address,'Tag','ScopeDataGUI');
        s.InputBufferSize=2500*8;
        try 
            fopen(s);
        catch
            set([handles.SerialPortMenu h handles.GPIBVendor handles.GPIBAddress handles.GPIBBoard],'Enable','on');
            warndlg(lasterr)
        end;
        
    end;
end;



fprintf(s,'Header 0');      %Turn headers off

fprintf(s,'Acquire:State stop');   %Stop acquisition

fprintf(s, 'Data:Source CH1');
fprintf(s, 'Data:Encdg SRPbinary');
fprintf(s, 'Data:Width 1');
fprintf(s, 'Data:Start 1');
fprintf(s, 'Data:Stop 2500');
fprintf(s, 'Curve?');

%Wait until enough data is ready, for serial port only
if com==1       %serial
    while s.BytesAvailable<2500,
    end
end;

% Discard first six bytes - describes data.
trash=fread(s, 6, 'int8');
% Read in the waveform.
data = fread(s, 2500, 'uint8');
% Read in the terminator.
trash = fread(s, 1, 'int8');

% Scale data.
ymult=query(s, 'WFMPre:YMult?','%s\n','%g');
yoff=query(s, 'WFMPre:YOff?','%s\n','%g');
yzero=query(s, 'WFMPre:YZEro?','%s\n','%g');
timeScale=query(s, 'Horizontal:main:scale?','%s\n','%g')*10; % 10 Divisions
data= (data - yoff)*ymult + yzero;
time = linspace(0,timeScale,length(data));


%Compute y axis limits
VpDiv = 25 * ymult;      %Volts per Division on scope

%There are 8 divisions on the scope
yaxlim = [-4 4]*VpDiv;

plot(time,data)
xlabel('Seconds');
ylabel('Volts');
axis([0 timeScale yaxlim]);

fprintf(s,'Acquire:State 1');   %Restart acquisition

fclose(s)
delete(s)

%Enable uicontrols
set(h,'Enable','on');
% set(handles.SerialPortMenu,'Enable','on');
% set(handles.GPIBBoard,'Enable','on');


%Try to turn on datalabel
try
    datalabel('on','ro');
end;


% --- Executes during object creation, after setting all properties.
function GPIBMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GPIBMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in GPIBMenu.
function GPIBMenu_Callback(hObject, eventdata, handles)
% hObject    handle to GPIBMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns GPIBMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GPIBMenu


% --- Executes during object creation, after setting all properties.
function ProtocolMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ProtocolMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in ProtocolMenu.
function ProtocolMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ProtocolMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ProtocolMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ProtocolMenu
val = get(hObject,'Value');
if val==1   %serial
    set(handles.SerialPortMenu,'Visible','on');
    set([handles.GPIBVendor],'Visible','off');
    set([handles.GPIBBoard handles.GPIBText handles.GPIBAddress],'Enable','off');
else    %GPIB
    set(handles.SerialPortMenu,'Visible','off');
    set([handles.GPIBVendor],'Visible','on');
    set([handles.GPIBBoard handles.GPIBText handles.GPIBAddress],'Enable','on');
end;

% --- Executes during object creation, after setting all properties.
function GPIBBoard_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GPIBBoard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function GPIBBoard_Callback(hObject, eventdata, handles)
% hObject    handle to GPIBBoard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GPIBBoard as text
%        str2double(get(hObject,'String')) returns contents of GPIBBoard as a double


% --- Executes during object creation, after setting all properties.
function GPIBVendor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GPIBVendor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in GPIBVendor.
function GPIBVendor_Callback(hObject, eventdata, handles)
% hObject    handle to GPIBVendor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns GPIBVendor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GPIBVendor


% --- Executes during object creation, after setting all properties.
function GPIBAddress_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GPIBAddress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function GPIBAddress_Callback(hObject, eventdata, handles)
% hObject    handle to GPIBAddress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GPIBAddress as text
%        str2double(get(hObject,'String')) returns contents of GPIBAddress as a double


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


