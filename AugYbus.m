function [Ly, Uy, Py] = AugYbus(Ybus, xd_tr, gbus, P, Q, U0)
Ybus = sparse(Ybus);
% Yload
yload = (P - j.*Q)./(abs(U0).^2);

% Ygen
ygen=zeros(size(Ybus,1),1);
ygen(gbus) = 1./(j.*xd_tr);

% add Ygen and Ybus
for i=1:size(Ybus,1)
    Ybus(i,i) = Ybus(i,i)+ ygen(i) + yload(i);
end

Y = Ybus;

% Factorise
[Ly,Uy,Py] = lu(Y,'vector');

return;