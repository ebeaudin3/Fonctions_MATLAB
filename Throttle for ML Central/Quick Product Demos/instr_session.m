s=serial('com1');           %Create
s.Timeout=1;                %Configure
fopen(s)                    %Connect
query(s,'*idn?')            %Communicate
fclose(s);                  %Disconnect / Clean Up
delete(s);
clear s