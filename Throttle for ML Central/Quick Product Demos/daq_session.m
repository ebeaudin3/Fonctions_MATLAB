% Create the object and add one channel
ai = analoginput('winsound');       %Create
addchannel(ai,1);                   

%Let's look at the object
ai

% Let's look at the object in more detail
get(ai)                    

%Configure the analog input parameters
set(ai, 'SampleRate', 44100);       %Configure

% Start the object.  With the default settings, it will
% record for 1 second.
start(ai)

%Get the data
[data,time]=getdata(ai);
plot(time,data)

%Clean up
delete(ai)
clear ai  

%Now, if we wanted to use our Measurement Computing Corp.
% Hardware, we would change only one line:
ai = analoginput('mcc',0);      %Board number 0

%Get information on hardware on my machine
daqhwinfo

%Lets look specifically for Meas.
%  Computing Corp. hardware
hw = daqhwinfo('mcc');

%But wait, there's more!
daqhwinfo(ai)