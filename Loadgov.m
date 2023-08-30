function Pgov = Loadgov(casefile_dyn)
%% Load data
if isstruct(casefile_dyn)
	gov = casefile_dyn.gov;
else
    [gen,exc,gov,freq,stepsize,stoptime] = feval(casefile_dyn);
end

%% Consecutive numbering or rows
Pgov = gov;

for i = 1:length(gov(1,:))
    Pgov(gov(:,1),i) = gov(:,i);
end

return;