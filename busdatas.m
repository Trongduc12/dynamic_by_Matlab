function [bus,line,gen] = busdatas
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
%	Pg Qg Qmax Qmin 
%         |Bus | Type | Vsp | theta | PGi | QGi | PLi | QLi | Qmin | Qmax |
bus = [     1     1    1.04     0     1000   0    0      0      0      0;
            2     2    1.025    0     1630   0    0      0      0      0;
            3     2    1.024    0     850    0    0      0      0      0;
            4     3    1.0      0     0.0    0    0      0      0     0;
            5     3    1.0      0     0.0    0    1250   500    0     0;
            6     3    1.0      0     0.0    0    900    300    0     0;
            7     3    1.0      0     0      0    0.0    0.0    0     0;
            8     3    1.0      0     0      0    1000   350    0     0;
            9     3    1.0      0     0      0    0      0      0     0;
];

%         |  From |  To   |   R     |   X     |     B/2  |  X'mer  |
%         |  Bus  | Bus   |  pu     |  pu     |     pu   | TAP (a) |
line =  [4	    5	    0.01	    0.085	    0.088	1;
	         4	    6	    0.017	    0.092	    0.079	1;
	         5	    7	    0.032	    0.161	    0.153	1;
	        6	    9	    0.039	    0.17	    0.179	1;
	        7	    8	    0.0085	    0.072	    0.0745	1;
	        8	    9	    0.01190	    0.1008	    0.1045	1;
	        1	    4	    0	        0.0576	    0	    1;
	        2	    7	    0	        0.0625	    0	    1;
	        3	    9	    0  	        0.0586	    0   	1;
        ];
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
gen = [
	1	1000	0	300	-300	1.04	1000	1	250	10	0	0	0	0	0	0	0	0	0	0	0;
	2	1630	0	300	-300	1.025	1000	1	300	10	0	0	0	0	0	0	0	0	0	0	0;
	3	850	    0	300	-300	1.024	1000	1	270	10	0	0	0	0	0	0	0	0	0	0	0;
];
end