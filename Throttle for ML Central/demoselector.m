function varargout = demoselector(varargin)
% DEMOSELECTOR Application M-file for demoselector.fig
%    FIG = DEMOSELECTOR launch demoselector GUI.
%    DEMOSELECTOR('callback_name', ...) invoke the named callback.
% Last Modified by GUIDE v2.0 04-Oct-2001 19:53:55
%Option:
%You can populate the list box with the contents of a text file
%This works one of two ways:
%  Have a file called demoselector.txt in the CURRENT DIRECTORY
%  Specify the file name (w/ .txt extension) as input:
%     demoselector('MyFile.txt');

% Copyright 2002 - 2003 The MathWorks, Inc

persistent demoroot

if isempty(demoroot)
    demoroot = pwd;
end;

if nargin == 0 | (nargin==1 & findstr(varargin{1},'.txt'))  % LAUNCH GUI
    fig = openfig(mfilename,'reuse');	% Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(fig);
    guidata(fig, handles);
    movegui(fig,'east');
    if nargout > 0
        varargout{1} = fig;
    end
    
    %Look for demoselector.txt
    
    %If a .txt file name was specified, use it as the contents of
    %  the example list box
    
    %Is there a file?
    % a) filename input
    % b) demoselector.txt in current directory
    
    isfile = 0;
    d = dir('demolist.txt');
    if (nargin==1 & findstr(varargin{1},'.txt')) | ~isempty(d)
        if nargin==1
            filename=varargin{1};
        else
            filename='demolist.txt';
        end;
        
        fid = fopen(filename);
        s={};
        warning off
        while ~feof(fid)
            line = fgetl(fid);
            s{end+1} = line;
        end;
        fclose(fid);
        warning on
        set(handles.example,'String',s);
        
        %Add Context Menu for help
        %Add context menu to the cursors
        cmenu = uicontextmenu('Parent',handles.figure1);
        set(handles.example,'UIContextMenu',cmenu);
        item1 = uimenu(cmenu, 'Label', 'Help on selected demonstration', ...
            'Callback', 'demoselector(''help_Callback'',gcbo,[],guidata(gcbo))');
        
        
        set(fig,'Visible','on');
        
        %Add path if necessary
        ps = path;              %Current path string
        np = genpath(pwd);      %Additional path
        if isempty(strfind(np,ps))
            addpath(np)
        end;
        
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
function varargout = example_Callback(h, eventdata, handles, varargin)
if strcmp(get(gcf,'SelectionType'),'open') % act on double click which is "open"
    s  = get(h,'string');
    sp = char(s(get(h,'value')));
    a=findstr('$',sp);
    if isempty(a)
        return
    end;
    sx = char(sp((a+1):end));
    evalin('base',sx,'disp([''fail to execute string: '',sx])');
end;

function varargout = help_Callback(h, eventdata, handles, varargin)
s  = get(handles.example,'string');
sp = char(s(get(handles.example,'value')));
a=findstr('$',sp);
if isempty(a)
    return
end;
sx = char(sp((a+1):end));

%The help file name is the demo name + Help.html
%Example:
%  mydemo.m
%  mydemoHelp.html

%First, get rid of "edit" if it's there
ind = findstr('edit ',sx);
if ~isempty(ind)
    sx = sx(ind+5:end);
end;
helpfile = [sx 'Help.html'];
DefPath = fileparts(which(sx)); 
DefPath = ['file:///' strrep(DefPath,filesep,'/') ];

URL = [ DefPath , '/html/',helpfile];

try
    web(URL)
catch
    msgbox(['Sorry, help is not available on ' sx]);
end;


