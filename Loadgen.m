function Pgen = Loadgen(casefile_dyn, output)
%% Load data
if isstruct(casefile_dyn)
    gen = casefile_dyn.gen;
else
    [gen,exc,gov,freq,stepsize,stoptime] = feval(casefile_dyn);
end

Pgen = gen;

genmodel = Pgen(:,2);


%% 
d=[1:length(genmodel)]';
type1 = d(genmodel==1);
type2 = d(genmodel==2);
type3 = d(genmodel==3);


%% type 2
xd_tr = Pgen(type2,9);
xq_tr = Pgen(type2,10);

if sum(xd_tr~=xq_tr)>=1
    if output; 
    fprintf('> \n'); 
    end
    Pgen(type2,10) = Pgen(type2,9);
end
%% type 3 
xd_tr = Pgen(type3,9);
xq_tr = Pgen(type3,10);
xd_2tr = Pgen(type3,11);
xq_2tr = Pgen(type3,12);
if sum(xd_2tr~=xq_2tr)>=1
    if output; 
    fprintf('> \n'); 
    end
    Pgen(type3,12) = Pgen(type3,11);
end
return;