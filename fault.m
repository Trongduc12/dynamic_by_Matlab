function [event,buschange,linechange,loadchange] = fault
%%
% event = [time     type]
event=[] ;  

% buschange = [time     bus(row)  attribute(col)    new_value]
buschange   = [1.03          2           6              -1e10
               1.05        2           6                 0];

% linechange = [time  line(row)  attribute(col)     new_value]
linechange = [  0.03       3          3              5e-11	
                0.03       3          4              5e-11
                0.1        3          4              0.161
                0.10       3          3               0.032];
% loadchange = [time  line(row)  attribute(col)     new_value]
loadchange = [1.04          5          4                800
              1.05          5          3                500];


return;