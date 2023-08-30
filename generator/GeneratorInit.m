function [Efd0,Xgen0] = GeneratorInit(Pgen, U0, gen, gentype,bus)

%% Init
global freq;

[ngen,c] = size(Pgen);
Xgen0 = zeros(ngen,1);
Efd0 = zeros(ngen,1);
d=[1:length(gentype)]';

%% Define types
type1 = d(gentype==1);
type2 = d(gentype==2);
type3 = d(gentype==3);

%% Generator type 1: classical model
%% Generator type 2: 4th order model
%% Generator type 2: 
xd = Pgen(type2,7);
xq = Pgen(type2,8);
xd_tr = Pgen(type2,9);
xq_tr = Pgen(type2,10);

omega0=ones(length(type2),1).*2.*pi.*freq;

% Initial machine armature currents
Ia0 = (bus(type2,3) - j.*bus(type2,4))./(conj(U0(type2,1)));
phi0=angle(Ia0);

% Initial Steady-state internal EMF
Eq0 = U0(type2,1) + j.*xq.*Ia0;
delta0 = angle(Eq0);

% Machine currents in dq frame
Id0 = -abs(Ia0).*sin(delta0 - phi0);
Iq0 = abs(Ia0).*cos(delta0 - phi0);

% Field voltage
Efd0(type2) = abs(Eq0) - (xd - xq).*Id0;

% Initial Transient internal EMF
Eq_tr0 = Efd0(type2,1) + (xd - xd_tr).*Id0;
Ed_tr0 = -(xq - xq_tr).*Iq0;

Xgen0(type2,1:4) = [delta0, omega0, Eq_tr0, Ed_tr0];
%% Generator type 3: 6th order model
xd = Pgen(type3,7);
xq = Pgen(type3,8);
xd_tr = Pgen(type3,9);
xq_tr = Pgen(type3,10);
xd_2tr = Pgen(type3,11);
xq_2tr = Pgen(type3,12);
xl = Pgen(type3,18);
omega0 = ones(length(type3),1).*2.*pi.*freq;

Ia0 = (bus(type3,3) - j.*bus(type3,4))./(conj(U0(type3,1))); % dong may phat
phi0 = angle(Ia0);

Eq0 = U0(type3,1) + j.*xq.*Ia0; % Ef ban dau
delta0 = angle(Eq0);

id = abs(Ia0).*sin(delta0 - phi0); % doc truc
iq = abs(Ia0).*cos(delta0 - phi0);  % ngang truc

Efd0(type3) = abs(Eq0) + (xd - xq).*id; % dien truong

Ed_tr0 = (xq - xq_tr).*iq;                                   
Ed_2tr0 = - Ed_tr0 - (xq_tr - xl ).*iq;
Eq_tr0 = -(xd - xd_tr).*id + Efd0(type3);
Eq_2tr0 = Eq_tr0 - (xd_tr - xl).*id;
Xgen0(type3,1:6) = [ delta0, omega0 , Eq_tr0, Ed_tr0, Eq_2tr0, Ed_2tr0];

return;