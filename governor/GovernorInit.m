function [Xgov0,Pgov0] = GovernorInit(Xgov, Pgov, Vgov, govtype)

%% Init
global freq;

[ngen,c] = size(Xgov);
Xgov0 = zeros(ngen,c);
[ngen,c] = size(Pgov);
Pgov0 = zeros(ngen,c+2);
d=[1:length(govtype)]';

%% Define types
type1 = d(govtype==1);
type2 = d(govtype==2);
type3 = d(govtype==3);
%% Governor type 1: constant power
%% Governor type 2: IEEE general speed-governing system
%% Governor type 3: 
Pm0 = Xgov(type3,1);
Pm = Pm0;
Xgov0(type3,1:2)= [Pm,Pm0];
Pgov0(type3,1)= [Pgov(type3,1)];


return;