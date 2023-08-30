function [Angles,Speeds,Eq_tr,Ed_tr,Efd,PM,Voltages,Stepsize,Errest,Time] = rundynamic(casefile_dyn, casefile_ev)
%% thoi gian
tic;
%% doc thu muc
addpath([cd '/generator/']);
addpath([cd '/exciter/']);
addpath([cd '/governor/']);
if nargin < 4
	mdopt = Mdoption;   
end
output = mdopt(5);

%% nhap du lieu dong
if output; disp('> Loading dynamic simulation data...'); end
global freq
[freq,stepsize,stoptime] = Loaddyn(casefile_dyn);

% thong so gen
Pgen0 = Loadgen(casefile_dyn, output);

% thong so exciter
Pexc0 = Loadexc(casefile_dyn);

% thong so gov
Pgov0 = Loadgov(casefile_dyn);

% thong so su co 
if ~isempty(casefile_ev)
    [event,buschange,linechange,loadchange] = Loadevents(casefile_ev);
else
    event=[];
end

genmodel = Pgen0(:,2);
excmodel = Pgen0(:,3);
govmodel = Pgen0(:,4);

%% Run power flow
baseMVA = 1000;
[line, bus ,gen, Ybus, Vm, del] = loadflow;
U0=Vm.*(cos(del) + j.*sin(del));
U00=U0;
% them may phat 
on = find(gen(:,8) > 0);    
gbus = gen(on, 1);               
ngen = length(gbus);
nbus = length(U0);

%% Construct augmented Ybus 
Pl=bus(:,5);                  %% Phu tai 
Ql=bus(:,6);
xd_tr = zeros(ngen,1);
xd_tr(genmodel==2) = Pgen0(genmodel==2,9);
xd_tr(genmodel==3) = Pgen0(genmodel==3,9);
[Ly, Uy, Py] = AugYbus( Ybus, xd_tr, gbus, Pl, Ql, U0);


%% Dieu kien dau
[Efd0, Xgen0] = GeneratorInit(Pgen0, U0(gbus), gen, genmodel,bus);
omega0 = Xgen0(:,2);
[Id0,Iq0,Pe0] = MachineCurrents(Xgen0, Pgen0, U0(gbus), genmodel);
Vgen0 = [Id0, Iq0, Pe0];

% Exciter 
Vexc0 = [abs(U0(gbus))];
[Xexc0,Pexc0] = ExciterInit(Efd0, Pexc0, Vexc0, excmodel);

% Governor 
Pm0 = Pe0;
[Xgov0, Pgov0] = GovernorInit(Pm0, Pgov0, omega0, govmodel);
Vgov0 = omega0;

% kiem tra

Fexc0 = Exciter(Xexc0, Pexc0, Vexc0, excmodel);
Fgov0 = Governor(Xgov0, Pgov0, Vgov0, govmodel);
Fgen0 = Generator(Xgen0, Xexc0, Xgov0, Pgen0, Vgen0, genmodel);

if sum(sum(abs(Fgen0))) > 1e-6
    fprintf('> Error: Generator not in steady-state\n> Exiting...\n')
    return;
end
% Check Exciter Steady-state
if sum(sum(abs(Fexc0))) > 1e-6
	fprintf('> Error: Exciter not in steady-state\n> Exiting...\n')
	return;
end
% Check Governor Steady-state
if sum(sum(abs(Fgov0))) > 1e-6
    fprintf('> Error: Governor not in steady-state\n> Exiting...\n')
    return;
end

%% Initialization of main stability loop
t=-2;
errest=0;
failed=0;
ev=1;
eventhappened = false;
i=0;


%% khoi tao bien
chunk = 5000;

Time = zeros(chunk,1); Time(1,:) = t;
Errest = zeros(chunk,1); Errest(1,:) = errest;
Stepsize = zeros(chunk,1); Stepsize(1,:) = stepsize;

% bien he thong
Voltages = zeros(chunk, length(U0)); Voltages(1,:) = U0.';

% Generator
Angles = zeros(chunk,ngen); 
Angles(1,:) = Xgen0(:,1);
Speeds = zeros(chunk,ngen); 
Speeds(1,:) = Xgen0(:,2)./(2.*pi.*freq);
Eq_tr = zeros(chunk,ngen);
Eq_tr(1,:) = Xgen0(:,3);
Ed_tr = zeros(chunk,ngen);
Ed_tr(1,:) = Xgen0(:,4);
Eq_2tr = zeros(chunk, ngen);
Eq_2tr(1,:) = Xgen0(:,5);
Ed_2tr = zeros(chunk,ngen);
Ed_2tr(1,:) = Xgen0(:,6);

% Exciter and governor
Efd = zeros(chunk,ngen); 
Efd(1,:) = Efd0(:,1);  
PM = zeros(chunk,ngen); 
PM(1,:) = Pm0(:,1);


%% Vong lap
while t < stoptime + stepsize

    %% Output    
    i=i+1;
    if mod(i,45)==0 && output
       fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b> %6.2f%% completed', t/stoptime*100)
    end  
    
    %% Runger - Kuttar
            [Xgen0, Pgen0, Vgen0, Xexc0, Pexc0, Vexc0, Xgov0, Pgov0, Vgov0, U0, t, newstepsize] = RungeKutta(t, Xgen0, Pgen0, Vgen0, Xexc0, Pexc0, Vexc0, Xgov0, Pgov0, Vgov0, Ly, Uy, Py, gbus, genmodel, excmodel, govmodel, stepsize);
	
    
    %% Luu bien moi
    if i>size(Time,1)
        Stepsize = [Stepsize; zeros(chunk,1)];
        Errest = [Errest; zeros(chunk,1)];
        Time = [Time; zeros(chunk,1)];
        Voltages = [Voltages; zeros(chunk,length(U0))];
        Efd = [Efd; zeros(chunk,ngen)];
        PM = [PM; zeros(chunk,ngen)];
        Angles=[Angles;zeros(chunk,ngen)];
        Speeds=[Speeds;zeros(chunk,ngen)];
        Eq_tr=[Eq_tr;zeros(chunk,ngen)];
        Ed_tr=[Ed_tr;zeros(chunk,ngen)];
        Eq_2tr=[Eq_tr;zeros(chunk,ngen)];
        Ed_2tr=[Ed_tr;zeros(chunk,ngen)];
    end

    
    %% Luu ket qua
    Stepsize(i,:) = stepsize.';
    Errest(i,:) = errest.';
    Time(i,:) = t;
    
    Voltages(i,:) = U0.';

    % exc
    Efd(i,:) = Xexc0(:,1).*(genmodel>1); 
    
    % gov
    PM(i,:) = Xgov0(:,1);
   
    % gen
	Angles(i,:) = Xgen0(:,1);
    Speeds(i,:) = Xgen0(:,2)./(2.*pi.*freq);
    Eq_tr(i,:) = Xgen0(:,3);
    Ed_tr(i,:) = Xgen0(:,4);   
    Eq_2tr(i,:) = Xgen0(:,5);
    Ed_2tr(i,:) = Xgen0(:,6);  
    %%  events
    if ~isempty(event) && ev <= size(event,1)    
           
        for k=ev:size(event,1)   
            if abs(t-event(ev,1))>10*eps ||  ev > size(event,1)                
                break;
            else
                eventhappened = true;
            end

                switch event(ev,2)
                    case 1
                        bus(buschange(ev,2),buschange(ev,3)) = buschange(ev,4);

                    case 2
                        line(linechange(ev,2),linechange(ev,3)) = linechange(ev,4); 
                    case 3
                        bus(loadchange(ev,2),loadchange(ev,3)) = loadchange(ev,4);
                end 
                ev=ev+1;
        end          
            
        if eventhappened
            % Refactorise
            [Ly, Uy, Py] = AugYbus( Ybus, xd_tr, gbus, bus(:,5), bus(:,6), U00);
            U0 = SolveNetwork(Xgen0, Pgen0, Ly, Uy, Py, gbus, genmodel);            
            
            [Id0,Iq0,Pe0] = MachineCurrents(Xgen0, Pgen0, U0(gbus), genmodel);
            Vgen0 = [Id0,Iq0,Pe0];
            Vexc0 = abs(U0(gbus));
            i=i+1; % if event occurs, save values at t- and t+

            %% Save values
            Stepsize(i,:) = stepsize.';
            Errest(i,:) = errest.';            
            Time(i,:) = t;
    
            Voltages(i,:) = U0.';

            % exc
            Efd(i,:) = Xexc0(:,1).*(genmodel>1); % Set Efd to zero when using classical generator model  
    
            % gov
            PM(i,:) = Xgov0(:,1);
   
            % gen
            Angles(i,:) = Xgen0(:,1);
            Speeds(i,:) = Xgen0(:,2)./(2.*pi.*freq);
            Eq_tr(i,:) = Xgen0(:,3);
            Ed_tr(i,:) = Xgen0(:,4);
            Eq_2tr(i,:) = Xgen0(:,5);
            Ed_2tr(i,:) = Xgen0(:,6);
            eventhappened = false;
        end
    end    

    
    %% Advance time    
    stepsize = newstepsize;
    t = t + stepsize;
    
end % end of main stability loop


%% Output
if output
    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b> 100%% completed')
else
    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b')
end
simulationtime=toc;
if output; fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b> Simulation completed in %5.2f seconds\n', simulationtime); end

% Save only the first i elements
Angles = Angles(1:i,:);
Speeds = Speeds(1:i,:);
Eq_tr = Eq_tr(1:i,:);
Ed_tr = Ed_tr(1:i,:);
Eq_2tr = Eq_2tr(1:i,:);
Ed_2tr = Ed_2tr(1:i,:);
Efd = Efd(1:i,:);
PM = PM(1:i,:);

Voltages = Voltages(1:i,:);

Stepsize = Stepsize(1:i,:);
Errest = Errest(1:i,:);
Time = Time(1:i,:);


%% Plot 
figure
xlabel('Time [s]')
ylabel('Angle [deg]')
hold on
Angles1 = Angles(:,1);
Angles2 = Angles(:,2);
Angles3 = Angles(:,3);
plot(Time,Angles1)
plot(Time,Angles2)
plot(Time,Angles3)
axis([0 Time(end) -1 1])
axis 'auto y'
legend('Angles1', 'Angles2','Angles3')

figure
xlabel('Time [s]')
ylabel('Speed [pu]')
hold on
plot(Time,Speeds)
axis([0 Time(end) -1 1])
axis 'auto y'

figure
xlabel('Time [s]')
ylabel('Voltage [pu]')
hold on
plot(Time,abs(Voltages))
axis([0 Time(end) -1 1])
axis 'auto y'

figure
xlabel('Time [s]')
ylabel('Excitation voltage [pu]')
hold on
plot(Time,Efd)
axis([0 Time(end) -1 1])
axis 'auto y'

figure
xlabel('Time [s]')
ylabel('Turbine Power [pu]')
hold on
plot(Time,PM)
axis([0 Time(end) -1 1])
axis 'auto y'

figure
hold on
xlabel('Time [s]')
ylabel('Step size')
plot(Time,Stepsize,'-o')
axis([0 Time(end) -1 1])
axis 'auto y'

figure 
hold on
xlabel( 'Time [s]')
ylabel( ' denta [do]')
denta1 = Angles(:,2)-Angles(:,1);
denta2 = Angles(:,3)-Angles(:,1);
plot(Time,denta1)
plot(Time,denta2)
axis([0 Time(end) -1 1])
axis 'auto y'

return;