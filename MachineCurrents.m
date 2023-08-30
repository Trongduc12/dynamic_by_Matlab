function [Id,Iq,Pe] = MachineCurrents(Xgen, Pgen, U, gentype)

%% Init
[ngen,c] = size(Xgen);
Id = zeros(ngen,1);
Iq = zeros(ngen,1);
Pe = zeros(ngen,1);
d = [1:length(gentype)]';

%% Define types
type1 = d(gentype==1);
type2 = d(gentype==2);
type3 = d(gentype==3);
%% Generator type 1: classical model
%% Generator type 2: 4th order model
delta = Xgen(type2,1);
Eq_tr = Xgen(type2,3);
Ed_tr = Xgen(type2,4);

xd_tr = Pgen(type2,9);
xq_tr = Pgen(type2,10);

theta=angle(U);

% Tranform U to rotor frame of reference
vd = -abs(U(type2,1)).*sin(delta-theta(type2,1));
vq = abs(U(type2,1)).*cos(delta-theta(type2,1));

Id(type2) = (vq - Eq_tr)./xd_tr;
Iq(type2) =-(vd - Ed_tr)./xq_tr;

Pe(type2) = Eq_tr.*Iq(type2,1) + Ed_tr.*Id(type2,1) + (xd_tr - xq_tr).*Id(type2,1).*Iq(type2,1);
%% Generator type 2: 6th order model

delta = Xgen(type3,1);
Eq_tr = Xgen(type3,3);
Ed_tr = Xgen(type3,4);
Eq_2tr = Xgen(type3,5);
Ed_2tr = Xgen(type3,6);
xd_tr = Pgen(type3,9);
xq_tr = Pgen(type3,10);
xd_2tr = Pgen(type3,11);
xq_2tr = Pgen(type3,12);
%
theta=angle(U);

% 
vd = abs(U(type3,1)).*sin(delta-theta(type3,1));
vq = abs(U(type3,1)).*cos(delta-theta(type3,1));

Id(type3) = -(vq - Eq_tr)./xd_tr;
Iq(type3) =(vd - Ed_tr)./xq_tr;

Pe(type3) = (Eq_2tr.*Iq(type3,1) + Ed_2tr.*Id(type3,1)) + (xd_2tr - xq_2tr).*Id(type3,1).*Iq(type3,1);

return;