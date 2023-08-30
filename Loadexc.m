function Pexc = Loadexc(casefile_dyn)
%% Load data
if isstruct(casefile_dyn)
	exc = casefile_dyn.exc;
else
    [gen,exc,gov,freq,stepsize,stoptime] = feval(casefile_dyn);
end

Pexc = exc;

for i = 1:length(exc(1,:))
    Pexc(exc(:,1),i) = exc(:,i);
end

return;