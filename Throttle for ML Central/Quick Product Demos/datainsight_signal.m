%I found some data. What is is?
[y,fs] = wavread('helicopter.wav');     %In \Extra Test and Measurement Demos\AcousticTracker\Source Code

%Look at the time series
plot(y)

%Lets play it.
soundsc(y,fs)

%Maybe spectral analysis will help.
specgramdemo(y,fs)