%throttle_simulation_init   Initialization file for Throttle Simulation

%Initial guess at parameters
m=.35;      %Mass
c=11;       %Damping
k=1;        %Stiffness

%Angles.  Specify as [0,1].  Map to [0,90].
angle_init = .2;    %Intentionally not very good
angle_maxopen = 1;
angle_open = 1;

