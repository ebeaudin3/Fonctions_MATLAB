function ConfigureTrigger(ai,TriggerDelay,TriggerRange,TriggerCondition);
%Configure trigger
ai.TriggerType = 'Software';
ai.TriggerCondition = TriggerCondition;
ai.TriggerChannel = ai.Channel;
ai.TriggerConditionValue = TriggerRange;
ai.TriggerDelay = TriggerDelay;
ai.TriggerRepeat = inf;
ai.SamplesPerTrigger = 750;


% Copyright 2002 - 2003 The MathWorks, Inc
