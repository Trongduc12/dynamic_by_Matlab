function [line,bus,gen, Ybus, Vmag,delta] = loadflow
% MVa base
Mbase = 1000;
% Line Data 
%            From       To      R           X      Y/2
linedata = [      4	        5	    0.01	    0.085	    0.088	;
	          4	        6	    0.017	    0.092	    0.079	;
	          5	        7	    0.032	    0.161	    0.153	;
	          6	        9	    0.039	    0.17	    0.179	;
	          7	        8	    0.0085	    0.072	    0.0745	;
	          8	        9	    0.01190	    0.1008	    0.1045	;
	          1	        4	    0	        0.0576	    0	    ;
	          2	        7	    0	        0.0625	    0	    ;
	          3	        9	    0  	        0.0586	    0   	; ];

% Bus Data
%         Bus No  Type  Pg      Qg          Pd       Qd      |V|    delta    Qmin    Qmax      
busdata = [     1     	1    0      0         0         0       1.04      0        0      0;
            2       2    1630   0         0         0       1.025     0        0      0;
            3       2    850    0         0         0       1.025     0        0      0;
            4       3    0      0         0.0       0       1         0        0      0;
            5       3    0      0         1250     500      1         0        0      0;
            6       3    0      0         0900     300      1         0        0      0;
            7       3    0      0         0         0       1.0       0        0      0;
            8       3    0      0         1000     350      1         0        0      0;
            9       3    0      0         0         0       1         0        0      0; ];
% Bus genmodel excmodel govmodel Sbase(MVA)  Pout(MW)  Xd  Xq  X'd  X'q X"d  X"q  T'd0  T'q0  T"d0  T"q0  R  XL  H(s) Status V 
 gendata = [1 1 1 1 1000 1000 1.569 1.548 0.324 0.918 0.249 0.249 5.14 0.500 0.0437 0.070 0.00 0.204 50 1 1.040;
 2 1 1 1 1000 1630 1.651 1.590 0.232 0.380 0.171 0.171 5.90 0.535 0.0330 0.078 0.00 0.102  9 1 1.025 ;
 3 1 1 1 1000 0850 1.220 1.160 0.174 0.250 0.134 0.134 8.97 1.500 0.0330 0.141 0.00 0.078  6 1 1.025 ];
%% Y Bus Formation
R = linedata(:,3);                                  % dien tro 
X=linedata(:,4);                                    % dien khang
B=1i*linedata(:,5);                                 % dung dan
Z = R+1i*X;                                         % tong tro
Y = 1./Z;                                           % ysh 
nline= length(linedata(:,1));                       % so nhanh 
nbus = max(max(linedata(:,1),linedata(:,2)));       % so bus
ng = length(find(busdata(:,2)==2));                 % so may phat 

Ybus = zeros(nbus,nbus);                            % khoi tao Ybus
for k=1:nline
    
    % ngoai duong cheo
    Ybus(linedata(k,1),linedata(k,2)) = Ybus(linedata(k,1),linedata(k,2)) - Y(k);
    Ybus(linedata(k,2),linedata(k,1)) = Ybus(linedata(k,1),linedata(k,2));
    
    % ten duong cheo
    Ybus(linedata(k,1),linedata(k,1)) = Ybus(linedata(k,1),linedata(k,1))+ Y(k) + B(k); 
    Ybus(linedata(k,2),linedata(k,2)) = Ybus(linedata(k,2),linedata(k,2))+ Y(k) + B(k);
end

Ymag = abs(Ybus);                                   % Ybus 
theta = angle(Ybus);                                % goc Ybus
G = real(Ybus);                                     % phan thuc
B = imag(Ybus);                                     % phan ao

%% 
type = busdata(:,2);                                % loai bus
Pg = busdata(:,3)./Mbase;                                  % cong suat kha dung may phat
Qg = busdata(:,4)./Mbase;                                  % cong suat vo cong may phat
Pd = busdata(:,5)./Mbase;                                  % cong suat kha dung tai
Qd = busdata(:,6)./Mbase;                                  % cong suat vo cong tai
Qmin=busdata(:,9)./Mbase;                                  % gioi han tren Q  
Qmax = busdata(:,10)./Mbase;                               % gioi han duoi Q
Vmag = busdata(:,7);                                % dien ap
delta = busdata(:,8);                               % goc dien ap
V = Vmag.*(cos(delta) + 1i*sin(delta));             % dien ap phuc
P_sch = Pg-Pd;                                      % cong suat kha dung nut
Q_sch = Qg-Qd;                                      % cong suat vo cong nut

%% vong lap newton raphson
accuracy = 1;                                       % sai so 
iter = 1;                                           % buoc lap
while accuracy >=1e-8 
% tinh toan ma tran denta P , denta Q

for i=2:nbus
% tri so cong suat nut 
    P_cal(i) = 0;                                   % cong suat P
    Q_cal(i) = 0;                                   % cong suat Q
        for n=1:nbus
        P_cal(i) = P_cal(i) + Vmag(i)*Vmag(n)*Ymag(i,n)*cos(theta(i,n)+delta(n) - delta(i));
        Q_cal(i) = Q_cal(i) - Vmag(i)*Vmag(n)*Ymag(i,n)*sin(theta(i,n)+delta(n) - delta(i));
        end
        
        %% kiem tra gioi han
        if Qmax(i) ~=0
            if Q_cal(i) > Qmax(i)
                Q_cal(i) = Qmax(i);
                busdata(i,2) = 3; 
            elseif Q_cal(i) < Qmin(i)
                Q_cal(i) = Qmin(i);
                busdata(i,2) = 3;  
            else
                busdata(i,2) = 2; 
                Vmag(i) = busdata(i,7);
            end
        end
        
end
% ma tran Mismath

DP = P_sch (2:nbus) - P_cal(2:nbus)';
DQ = Q_sch ([find(busdata(:,2)==3)]) - Q_cal([find(busdata(:,2)==3)])';


%% tinh toan jacobi

% J1 
J1 = zeros(nbus,nbus);
for i=1:nbus
    for n=1:nbus
        if n~=i
            J1(i,i) = J1(i,i) + Vmag(i)*Vmag(n)*Ymag(i,n)*sin(theta(i,n)+delta(n)-delta(i));           
            J1(i,n) = - Vmag(i)*Vmag(n)*Ymag(i,n)*sin(theta(i,n)+delta(n)-delta(i));
            J1(n,i) = J1(i,n);
        end
    end
end
J11 = J1([find(busdata(:,2)~=1)], [find(busdata(:,2)~=1)]);


% J2
J2 = zeros(nbus,nbus);
for i=1:nbus
    for n=1:nbus 
        if n~=i
            J2(i,i) = J2(i,i) + Vmag(n)*Ymag(i,n)*cos(theta(i,n)+delta(n)-delta(i));           
            J2(i,n) =  Vmag(i)*Ymag(i,n)*cos(theta(i,n)+delta(n)-delta(i));
            J2(n,i) = J2(i,n);
        else
            J2(i,i) = J2(i,i) + 2*Vmag(i)*Ymag(i)*cos(theta(i,i));
        end
    end
end
J22 = J2([find(busdata(:,2)~=1)], [find(busdata(:,2)==3)]);

% J3
J3 =  zeros(nbus,nbus);
for i=1:nbus 
    for n=1:nbus
        if n~=i
            J3(i,i) = J3(i,i) + Vmag(i)*Vmag(n)*Ymag(i,n)*cos(theta(i,n)+delta(n)-delta(i));
            J3(i,n) = -Vmag(i)*Vmag(n)*Ymag(i,n)*cos(theta(i,n)+delta(n)-delta(i));
            J3(n,i) = J3(i,n);
        end
    end
end
J33 =J3([find(busdata(:,2)==3)], [find(busdata(:,2)~=1)]);


% J4
J4 = zeros(nbus,nbus);
for i = 1:nbus 
   
        for n=1:nbus
            if n == i
                J4(i,i) = J4(i,i) -2*Vmag(i)*Ymag(i,i)*sin(theta(i,i));
            else
                J4(i,i) = J4(i,i) - Vmag(n)*Ymag(i,n)*sin(theta(i,n)+delta(n)-delta(i));
            end
        end
   
end

 J44 = J4([find(busdata(:,2)==3)],[find(busdata(:,2)==3)]);


J = [J11 J22 ; J33 J44 ];
%  tinh ma tran

DF = [DP;DQ];
DX = J\DF;

delta([find(busdata(:,2)~=1)]) = delta([find(busdata(:,2)~=1)])+ DX(1:length(find(busdata(:,2)~=1)));
Vmag([find(busdata(:,2)==3)]) = Vmag([find(busdata(:,2)==3)]) + DX(length([find(busdata(:,2)~=1)])+1:length(DX));

accuracy = norm(DF);
iter = iter+1;
end

%% To find Slack bus power
for n=1:nbus
    Pg(1) = Pg(1) + Vmag(1)*Vmag(n)*Ymag(1,n)*cos(theta(1,n)+delta(n) - delta(1));
    Qg(1) = Qg(1) - Vmag(1)*Vmag(n)*Ymag(1,n)*sin(theta(1,n)+delta(n) - delta(1));
end

%% cong suat nut slack
for i=[find(busdata(:,2)==2)]
    for n=1:nbus
        Qg(i) = Qg(i) - Vmag(i).*Vmag(n).*Ymag(i,n).*sin(theta(i,n)+delta(n) - delta(i));      
    end
end

%% dien ap phuc 
Vm = Vmag.*(cos(delta)+j*sin(delta));

%% tinh dong dien tren cac nhanh 
Iij = zeros(nbus,nbus);
Sij = zeros(nbus,nbus);
fb = linedata(:,1);
tb = linedata(:,2);
% dong dien
 for m = 1:nbus
     for n = 1:nline
         if fb(n) == m
             p = tb(n);
             Iij(m,p) = -(Vm(m) - Vm(p))*Ybus(m,p) + B(n)*Vm(m);  
             Iij(p,m) = -(Vm(p) - Vm(m))*Ybus(p,m) + B(n)*Vm(p);
         elseif tb(n) == m
             p = fb(n);
             Iij(m,p) = -(Vm(m) - Vm(p))*Ybus(p,m) + Y(n)*Vm(m);
             Iij(p,m) = -(Vm(p) - Vm(m))*Ybus(m,p) + B(n)*Vm(p);
         end
     end
 end
 for m = 1:nbus
     for n = 1:nbus
         if m ~= n
             Sij(m,n) = Vm(m)*conj(Iij(m,n));
         end
     end
 end
 Pij = real(Sij);
 Qij = imag(Sij);
 %% ton that 
 Lij = zeros(nline,1);
 for m = 1:nline
     p = fb(m); q = tb(m);
     Lij(m) = Sij(p,q) + Sij(q,p);
 end
 Lpij = real(Lij);
 Lqij = imag(Lij);
 
 %% cong suat nut
 Si = zeros(nbus,1);
 for i = 1:nbus
     for k = 1:nbus
         Si(i) = Si(i) + conj(Vm(i))* Vm(k)*Ybus(i,k);
     end
 end
 Pi = real(Si);
 Qi = -imag(Si);
 Pg = Pi+Pd;
 Qg = Qi+Qd;
 %% update du lieu moi 
 MVAbase = Mbase;
 busdata(:,3:4) = [Pg, Qg];
 line = linedata;
 bus  = busdata;
 gen = gendata;
 
end