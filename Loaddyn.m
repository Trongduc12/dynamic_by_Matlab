function [freq,stepsize,stoptime]=Loaddyn(casefile_dyn)
%%
if isstruct(casefile_dyn)
	freq = casefile_dyn.freq;
    stepsize = casefile_dyn.stepsize;
    stoptime = casefile_dyn.stoptime;
else
    [gen,exc,gov,freq,stepsize,stoptime] = feval(casefile_dyn);
end

return;