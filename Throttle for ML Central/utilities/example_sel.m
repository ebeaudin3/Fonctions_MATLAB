function varargout = example_sel(varargin)
% EXAMPLE_SEL Application M-file for example_sel.fig
%    FIG = EXAMPLE_SEL launch example_sel GUI.
%    EXAMPLE_SEL('callback_name', ...) invoke the named callback.
% Last Modified by GUIDE v2.0 04-Oct-2001 19:53:55
%Option:
%You can populate the list box with the contents of a text file
%This works one of two ways:
%  Have a file called example_sel.txt in the CURRENT DIRECTORY
%  Specify the file name (w/ .txt extension) as input:
%     example_sel('MyFile.txt');

% Copyright 2001 - 2003 The MathWorks, Inc

if nargin == 0 | (nargin==1 & findstr(varargin{1},'.txt'))  % LAUNCH GUI
    fig = openfig(mfilename,'reuse');	% Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);
    guidata(fig, handles);
    movegui(fig,'southeast');
    if nargout > 0
        varargout{1} = fig;
    end
    
    %Look for example_sel.txt
    
    %If a .txt file name was specified, use it as the contents of 
    %  the example list box
    
    %Is there a file?
    % a) filename input
    % b) example_sel.txt in current directory
    
    isfile = 0;
    d = dir('example_sel.txt');
    if (nargin==1 & findstr(varargin{1},'.txt')) | ~isempty(d)
        if nargin==1
            filename=varargin{1};
        else
            filename='example_sel.txt';
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
    end;   
    
    set(fig,'Visible','on');
    
    
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

