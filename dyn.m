function [gen,exc,gov,freq,stepsize,stoptime] = dyn
%% General data
freq = 50;
stepsize = 0.01;
stoptime = 10;

% Bus genmodel excmodel govmodel Sbase(MVA)  Pout(MW)  Xd  Xq  X'd  X'q X"d  X"q  T'd0  T'q0  T"d0  T"q0  R  XL  H(s) Status V 
 gen = [1 3 3 3 1000 1000 1.569 1.548 0.324 0.918 0.249 0.249 5.14 0.500 0.0437 0.070 0.00 0.204 50 1 1.040;
        2 3 3 3 1000 1630 1.651 1.590 0.232 0.380 0.171 0.171 5.90 0.535 0.0330 0.078 0.00 0.102  9 1 1.025 ;
        3 3 3 3 1000 0850 1.220 1.160 0.174 0.250 0.134 0.134 8.97 1.500 0.0330 0.141 0.00 0.078  6 1 1.025 ];
 %% Exciter data
% [gen Ka  Ta  Ke  Te  Kf  Tf  Aex  Bex  Ur_min  Ur_max] IEEE
% [gen Ka Ta ] classic
exc=[1 25    0.5       0       0       0       0   0       0       0       0;
     2 25    0.5       0       0       0       0   0       0       0       0;
     3 24    0.5       0       0       0       0   0       0       0       0];
%% Governor data
% [gen K  T1  T2  T3  Pup  Pdown  Pmax  Pmin]
% [gen Kg Tg] classic
gov=[1  20   2   0   0   0   0   0   0;
     2  20   2   0   0   0   0   0   0;
     3  20   2   0   0   0   0   0   0];

return;