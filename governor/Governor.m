function F = Governor(Xgov, Pgov, Vgov, govtype)
%% Init
global freq;
omegas=2*pi*freq;

[r,c] = size(Xgov);
F = zeros(r,c);
d=[1:length(govtype)]';

%% Define governor types
type1 = d(govtype==1);
type2 = d(govtype==2);
type3 = d(govtype==3);
%% Governor type 1: constant power  
%% Governor type 2: IEEE general speed-governing system
%% Governor type 3
Pm0 = Xgov(type3,2);
Pm = Xgov(type3,1);
Kg = 20;
Tg = 2;
omega = Vgov(type3,1);
dPm = 1./Tg.*(Kg.*(omegas-omega)-(Pm-Pm0));
F(type3,1)=dPm;


return;