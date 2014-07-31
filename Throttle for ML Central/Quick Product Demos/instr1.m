% Create the serial object and set the Timeout to be 1 second
s=serial('com1')
%s=visa('ni','ASRL1::INSTR')
s.Timeout=1;
get(s)

% Open the serial object
fopen(s)

% Find out what hardware is on the other end of the line
query(s,'*idn?')

%  Find out the current contrast setting
value=query(s,'display:contrast?')

% Make the screen white
fprintf(s,'display:contrast 0')

% Make the screen black
fprintf(s,'display:contrast 100')

% Set the contrast back to the original setting
fprintf(s,['display:contrast ' value])

% Check the volt range for channel 1 and modify it
value=query(s,'ch1:volts?')
fprintf(s,'ch1:volts 1.0e-2')
fprintf(s,'ch1:volts 1.0e0')

fclose(s);
delete(s);
clear s