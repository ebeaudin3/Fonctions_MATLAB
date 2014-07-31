%Create and configure dio object
dio = CreateDIO;

%Start by opening and closing the throttle.
putvalue(dio,[1 0]);            %Open

putvalue(dio,[0 1]);            %Close

putvalue(dio,[0 0]);            %Relax

%Create and configure ai object
filename = 'LiveData';          %For saving the data
ai = CreateAI(filename);
start(ai)

%Look at the object
ai

%Open the throttle.  This triggers ai
putvalue(dio,[1 0]);            %Open


%Look again - see that it triggered
ai

putvalue(dio,[0 0]);            %Relax

%Get and plot the data
[time,position] = plotdata(ai);

%Export as spreadsheet file
export(filename,time,position);

stop(ai);
delete([ai dio]);