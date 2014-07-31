% Create the object and add one channel
ao=analogoutput('winsound')
addchannel(ao,1)

% Let's look at the object
get(ao)                    

% Create the signal and place it in the output buffer
snd=chirp(0:1/ao.SampleRate:5,500,2.5,3000)';
putdata(ao,snd)

% Let's see that the data is there
ao 

% Start the object and listen to the tone
start(ao)

