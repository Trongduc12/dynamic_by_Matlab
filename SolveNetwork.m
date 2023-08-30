function [U] = SolveNetwork(Xgen, Pgen, Ly, Uy, Py, gbus, gentype)
%% Init
ngen = length(gbus);
Igen = zeros(ngen,1);

s=length(Py);

Ig = zeros(s,1);
d = [1:length(gentype)]';

%% Define generator types
type1 = d(gentype==1);
type2 = d(gentype==2);
type3 = d(gentype==3);
%% Generator type 1: classical model
%% Generator type 2: 4th order model
%% generator type 3: 6th order model
delta = Xgen(type3,1);
Eq_tr = Xgen(type3,3);
Ed_tr = Xgen(type3,4);

xd_tr = Pgen(type3,9);

% Calculate generator currents
Igen(type3) = (Eq_tr + j.*Ed_tr).*exp(j.*delta)./(j.*xd_tr);
%%
% Generator currents
Ig(gbus) = Igen;

% U = Y/Ig
U = Uy\(Ly\Ig(Py));

return;