function [Xexc0,Pexc0] = ExciterInit(Xexc, Pexc, Vexc, exctype)

%% Init
[ngen,c] = size(Xexc);
Xexc0 = zeros(ngen,c);
[ngen,c] = size(Pexc);
Pexc0 = zeros(ngen,c+2);
d=[1:length(exctype)]';

%% Define types
type1 = d(exctype==1);
type2 = d(exctype==2);
type3 = d(exctype==3);
%% Exciter type 1: constant excitation
%% Exciter type 2: IEEE DC1A 
%% Exciter type 3
Efd0 = Xexc(type3,1);
U = Vexc(type3,1);
Uref = U;
Efd = Efd0;
Xexc0(type3,1:2) = [Efd,Efd0];
Pexc0(type3,1:2)=[Pexc(type3,1),Uref];


return;