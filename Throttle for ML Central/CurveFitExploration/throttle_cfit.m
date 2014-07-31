function slope = throttle_cfit(t,position,makeplot)
%THROTTLE_CFIT    Create plot of datasets and fits
%   Slope = THROTTLE_CFIT(T,POSITION)
%     Returns slope
%   Creates a plot, similar to the plot in the main curve fitting
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with cftool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  2
%   Number of fits:  1

% Copyright 2002 - 2003 The MathWorks, Inc

%I customized this routine slightly:
%  - Returns the slope of the fitted line
%  - Displays slope on the plot
%  - Has an option to not graph results

if nargin<3
    makeplot=1;
end;


% Data from dataset "position vs. t":
%    X = t:
%    Y = position:
%    Unweighted

% Data from dataset "position vs. t (smooth)":
%    X = t:
%    Y = position:
%    Unweighted
%
% This function was automatically generated

% Set up figure to receive datasets and fits
if makeplot
    f_ = clf;
    figure(f_);
    legh_ = []; legt_ = {};   % handles and text for legend
    xlim_ = [Inf -Inf];       % limits of x axis
    ax_ = subplot(1,1,1);
    set(ax_,'Box','on');
    axes(ax_); hold on;
end;

% --- Plot data originally in dataset "position vs. t"
t = t(:);
position = position(:);
% This dataset does not appear on the plot
% Add it to the plot by removing the if/end statements that follow
% and by selecting the desired color and marker
if 0
    h_ = line(t,position,'Color','r','Marker','.','LineStyle','none');
    xlim_(1) = min(xlim_(1),min(t));
    xlim_(2) = max(xlim_(2),max(t));
    legh_(end+1) = h_;
    legt_{end+1} = 'position vs. t';
end       % end of "if 0"

% --- Plot data originally in dataset "position vs. t (smooth)"
sm_.y2 = smooth(t,position,5,'moving',0);
if makeplot
    h_ = line(t,sm_.y2,'Parent',ax_,'Color',[0.333333 0.666667 0],...
        'LineStyle','none', 'LineWidth',1,...
        'Marker','.', 'MarkerSize',12);
    xlim_(1) = min(xlim_(1),min(t));
    xlim_(2) = max(xlim_(2),max(t));
    legh_(end+1) = h_;
    legt_{end+1} = 'position vs. t (smooth)';
end;

% --- Create fit "Rise"

% Apply excluded set "Rise Region"
if length(t)~=750
    error('Excluded set "Rise Region" is incompatible with t');
end
ex_ = logical(ones(length(t),1));
ex_([[(146:316)]]) = 0;
ft_ = fittype('poly1' );

% Fit this model using new data
cf_ = fit(t,sm_.y2,ft_ ,'Exclude',ex_);
coeff = coeffvalues(cf_);
slope = coeff(1);


% Or use coefficients from the original fit:
if 0
    cv_ = {393.9563235611, 60.3761261995};
    cf_ = cfit(ft_,cv_{:});
end

if makeplot
    h_ = plot(cf_,'predobs',0.95);
    legend off;  % turn off legend from plot method call
    set(h_(1),'Color',[1 0 0],...
        'LineStyle','-', 'LineWidth',2,...
        'Marker','none', 'MarkerSize',6);
    legh_(end+1) = h_(1);
    legt_{end+1} = 'Rise';
    if length(h_)>1
        set(h_(2:end),'Color',[1 0 0],...
            'LineStyle',':', 'LineWidth',1,'Marker','none');
        legh_(end+1) = h_(2);
        legt_{end+1} = 'Pred bnds (Rise)';
    end
    
    %Label slope on plot
    th = text(.08,44,{'    Rise';['-------------  = ' num2str(slope,4) '\circ/s'];'Rise Time'}, ...
        'FontWeight','Bold','FontSize',14);
    hold off;
    legend(ax_,legh_, legt_);
    axis([-.25 .5 20 90]);
end;

