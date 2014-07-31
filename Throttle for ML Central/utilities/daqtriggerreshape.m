function data = daqtriggerreshape(data);
%daqtriggerreshape    Reshape triggered daq data
%
% When we grab data which spans multiple triggers,
%  the data is separated by NaNs
% This function strips out the NaNs and reshapes
%  the data, adding one dimension for triggers.
%  There will be one "column" in the extra dimension
%  for each trigger
%
% Examples:
% - Single Channel
% y = daqtriggerreshape(x)
%   x: (Ns + Ntrigger-1) *Ntrigger x 1 (with NaNs)
%   y: Ns x Ntrigger
%
%Input: 1 Channel.  5 triggers of 1000 sample each
%   The input vector will be 5004 samples long, with
%     4 NaN's separating the triggers.
%   The output vector will by 1000 x 5
%
% - Multiple Channels
% Y = daqtriggerreshape(X)
%   x: (Ns + Ntrigger-1) *Ntrigger x NChannels
%   y: Ns x NChannels x Ntrigger
%
%Input: 3 Channels.  5 triggers of 1000 sample each
%   The input matrix will be 5004 x 3, with
%     4 NaN's separating the triggers.
%   The output vector will by 1000 x 3 x 5

% Scott Hirsch   2/20/02
% shirsch@mathworks.com
% Copyright 2002 - 2003 The MathWorks, Inc
% 

[Npts,NChannels] = size(data);
notnans = find(~isnan(data(:,1)));
NTriggers = Npts - length(notnans) + 1;
NSamples = length(notnans) / NTriggers;
data = reshape(data(notnans,:),NSamples,NTriggers,NChannels);
data = squeeze(permute(data,[1 3 2]));   %NSamples x NChannels x NTriggers
