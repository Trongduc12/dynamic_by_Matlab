function F = Generator(Xgen, Xexc, Xgov, Pgen, Vgen, gentype)

%% Init
global freq;
omegas=2*pi*freq;

[r,c] = size(Xgen);
F = zeros(r,c);
d=[1:length(gentype)]';

%% Define generator types
type1 = d(gentype==1);
type2 = d(gentype==2);
type3 = d(gentype==3);

%% Generator type 1: classical model
%% Generator type 2: 4th order model
omega = Xgen(type2,2);
Eq_tr = Xgen(type2,3);
Ed_tr = Xgen(type2,4);

H = Pgen(type2,19);
D = 2;
xd = Pgen(type2,7);
xq = Pgen(type2,8);
xd_tr = Pgen(type2,9);
xq_tr = Pgen(type2,10);
Td0_tr = Pgen(type2,13);
Tq0_tr = Pgen(type2,14);

Id = Vgen(type2,1);
Iq = Vgen(type2,2);
Pe = Vgen(type2,3);

Efd = Xexc(type2,1);
Pm = Xgov(type2,1);

ddelta = omega - omegas;
domega = pi .* freq ./ H .* (-D.*(omega - omegas) + Pm - Pe);
dEq = 1./Td0_tr .* (Efd - Eq_tr + (xd - xd_tr).*Id);
dEd = 1./Tq0_tr .* (-Ed_tr - (xq - xq_tr).*Iq);

F(type2,1:4) = [ddelta domega dEq dEd];
%% Generator type 3: 6th order model
% thong so dau 
omega = Xgen(type3,2);
xd = Pgen(type3,7);
xq = Pgen(type3,8);
xd_tr = Pgen(type3,9);
xq_tr = Pgen(type3,10);
xd_2tr = Pgen(type3,11);
xq_2tr = Pgen(type3,12);
Td0_tr = Pgen(type3,13);
Tq0_tr = Pgen(type3,14);
Td0_2tr = Pgen(type3,15);
Tq0_2tr = Pgen(type3,16);
xl = Pgen(type3,18);
H = Pgen(type3,19);
D = 2;
% thong so may phat tinh toan
Id = Vgen(type3,1);
Iq = Vgen(type3,2);
Pe = Vgen(type3,3);
Eq_tr = Xgen(type3,3);
Ed_tr = Xgen(type3,4);
Eq_2tr = Xgen(type3,5);
Ed_2tr = Xgen(type3,6);
Efd = Xexc(type3,1);
Pm = Xgov(type3,1);
% tinh toan 
ddelta = omega - omegas;                                        % sach Peter sauer pg.42
domega = pi .* freq ./ H .* ( Pm - Pe);
dEq_tr = 1./Td0_tr .* (Efd - Eq_tr - (xd - xd_tr).*Id);
dEd_tr = 1./Tq0_tr .* (-Ed_tr + (xq - xq_tr).*Iq);
dEq_2tr = 1./Td0_2tr .* (-Ed_tr - Ed_2tr  - (xq_tr - xl).*Iq);
dEd_2tr = 1./Tq0_2tr .* (Eq_tr - Eq_2tr - (xd_tr - xl).*Id);
% output 
F(type3,1:6) = [ddelta,domega, dEq_tr, dEd_tr,dEq_2tr,dEd_2tr];
%% Generator type 4:

return;