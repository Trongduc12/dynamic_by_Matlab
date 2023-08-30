function [event,buschange,linechange,loadchange]=Loadevents(casefile_ev)
%%
if isstruct(casefile_ev)
    event = casefile_ev.event;
    type1 = casefile_ev.buschange;
    type2 = casefile_ev.linechange;
    type3 = casefile_ev.loadchange;
else
    [event,type1,type2,type3] = feval(casefile_ev);
end
buschange=zeros(size(event,1),4);
linechange=zeros(size(event,1),4);
loadchange=zeros(size(event,1),4);

i1=1;
i2=1;
i3=1;
for i=1:size(event,1)
    if event(i,2)==1
        buschange(i,:) = type1(i1,:);
        i1=i1+1;     
	elseif event(i,2)==2
        linechange(i,:) = type2(i2,:);
        i2=i2+1;
    elseif event(1,2)==3
        loadchange(i,:) = type3(i3,:);
        i3=i3+1;

    end
end
        
return;