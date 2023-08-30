function F = Exciter(Xexc, Pexc, Vexc, exctype)
%% Init
[r,c] = size(Xexc);
F = zeros(r,c);
d=[1:length(exctype)]';

%% Define exciter types
type1 = d(exctype==1);
type2 = d(exctype==2);
type3 = d(exctype==3);
%% Exciter type 1: constant excitation  
%% Exciter type 2: IEEE DC1A
%% Exciter type 3: 
Efd = Xexc(type3,1);
Ka = 25;
Ta = 0.5;
U = Vexc(type3,1);
Uref = Pexc(type3,2);
Efd0 = Xexc(type3,2);
dEfd = 1./Ta.*(Ka.*(Uref - U) - (Efd - Efd0));
F(type3,1)= dEfd;


return;