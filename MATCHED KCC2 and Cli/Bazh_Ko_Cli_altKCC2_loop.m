clear;

tic

% max - maximal variations values
IKCC2_max=0.5;
HCO3_max=5;

% variations
dKCC2=0.1;     % mM
dHCO3=1;    % mM

% starting values
HCO3i=0;    % mM
IKCC2_E=0;      % mM

% set up the initial matrix
N_spike=zeros(IKCC2_max/dKCC2,HCO3_max/dHCO3);
Cl_end=zeros(IKCC2_max/dKCC2,HCO3_max/dHCO3);

% axis for the concentrations
X=(1:1:round(IKCC2_max/dKCC2))*dKCC2;
Y=(1:1:round(HCO3_max/dHCO3))*dHCO3;


for k=1:1:round(IKCC2_max/dKCC2)
    
    parfor p=1:1:round(HCO3_max/dHCO3)  % should be parfor


%% NUMERICAL PARAMETERS

T=5000;        % total time, mS
Tstart=1000;
Tend=Tstart+200;      % duration of the stimulation, ms
dt=0.05;         % time step, ms
t=(0:1:round(T/dt))*dt;
delta_I=0;
delta_E=0;

%% Stimulus parameters
Hz_stim=100;  % stimulation intensity
%

%% PY parameters

% Variation parameters
HCO3i=k*dHCO3;      % mM
Ikcc2_E=p*dKCC2;          % mM

stimulation_gain=4;

Mg=1;
% CL
Clo_E=124.8;        % mM
Vhalf_E=40;       % KCC2 1/2, was 40 
%Ikcc2_E=0.2;        % KCC2 max current
kCL_E=100;        % CL conversion factor, 1000 cm^3
% K
Ki_E=130;         % intra K, mM
kK_E=10;          % K conversion factor, 1000 cm^3
d_E=0.15;         % ratio Volume/surface, mu m
% NA
Nao_E=130;        % extra Na, mM
Nai_E=20;         % intra Na, mM
kNa_E=10;         % NA conversion, 1000 cm^3
% single cell and membrane parameters
Cm_E=0.75;         % mu F/cm^2

Temp=310;          % real temperature, correction
R=8.3;
F=96000;
P_Cl_HCO3=0.2;

e0_E=R*Temp/F*1000;      % RT/F, rescale all reversal potentials!

kappa_E=10000;     % conductance between compartments, Ohm
S_Soma_E=0.000001; % cm^2
S_Dend_E=0.000165; % cm^2
% constants
F=96000;        % coul/M
% Conductances
% somatic
G_Na_E=3450.0;     % Na, mS/cm^2
G_Kv_E=200.0;      % Kv-channel mS/cm^2
gg_kl_E=0.042;     % K leak, mS/cm^2
gg_Nal_E=0.0198;   % Na leak, mS/cm^2
Vbolz_E=22;        % mV
% dendritic
G_NaD_E=0;       % mS/cm^2 
G_NapD_E=0;      % mS/cm^2
G_HVA_E=0;    % mS/cm^2
G_kl_E=0.037;      % K leak, mS/cm^2
G_lD_E=0.00;       % Clleak, mS/cm^2        % leak changed
G_Nal_E=0.02;      % Na leak, mS/cm^2
E_Ca_E=140;        % mV
TauCa_E=300;       % ms
DCa_E=0.85;        % ???
G_KCa_E=0;       % mS/cm^2
G_Km_E=0;       % mS/cm^2
% Pump parametes and glial buffer
Koalpha_E=3.5;    % mM
Naialpha_E=20;    % mM
Imaxsoma_E=25;    % muA/cm^2  25
Imaxdend_E=25;    % muA/cm^2  25
Kothsoma_E=15;    % mM
koff_E=0.0008;    % 1/ mM / ms
K1n_E=1.0;        % 1/ mM
Bmax_E=500;       % mM
% KCC2 norm
HCO3o=25;       % mM
%HCO3i=16;       % mM

ts=1;            % stimulation starts always at first ms!

dts=Tend/Hz_stim;                 % shift for stimulation frequency

%HZ=Hz_stim;              % frequency of stimulation, Hz

%% ICS/Parameters Synaptic input, approximations from Chizhov et al 2002

% SYNAPTIC INPUT
% GABA
ggGABA_ext=0;
gGABA_ext=0;
% AMPA
ggAMPA_ext=0;
gAMPA_ext=0;
% NMDA
ggNMDA_ext=0;
gNMDA_ext=0;

% GABA-A
alpha1_GABA=0.1;          % kHz
alpha2_GABA=0.1;          % kHz
%AMPA
alpha1_AMPA=0.5;          % kHz
alpha2_AMPA=0.5;          % kHz
V_AMPA=5;                 % mV
%NMDA
alpha1_NMDA=0.05;         % kHz
alpha2_NMDA=0.05;         % kHz 
VNMDA=10;                 % mV


gGABA_max=stimulation_gain*0.5;          % mS/cm^2, estimated from Chizhov 0.5
gAMPA_max=stimulation_gain*0.5;          % mS/cm^2, estimated from Chizhov 0.5
gNMDA_max=stimulation_gain*0.1;          % mS/cm^2 0.1


%% INITIAL CONDITIONS (rest state, KCC2(+))
Ko=3.49;             % mM
Cli=4.09;            % mM
cai=0.00;            % mM
Bs=499.92;           % mM
VD=-59.41;           % mV
VSOMA=-59.45;        % mV
VGABA=-61.50;           % mV
m_iKv=0.013;       % 1
m_iNa=0.03;       % 1
h_iNa=0.65;       % 1
m_iKm=0.03;       % 1
m_iNaD=0.03;      % 1
h_iNaD=0.64;      % 1
m_iNapD=0.00;     % 1
m_iKCa=0.00;      % 1
m_iHVA=0.00;      % 1
h_iHVA=0.50;      % 1

%% loop over time
for i=1:1:round(T/dt)     
   
% delta function approximation
    if i*dt>=Tstart        % stimulate only if it is inbetween t1 and t2
        if i*dt<=Tend      % stimulation only during the stimulation period
        if i*dt==ts        % generation of stimulus times
            delta_I=1/dt;
            delta_E=1/dt;
            ts=ts+dts;
        else
            delta_I=0;
            delta_E=0;
        end
        else               % count the seizure duration after the stimulus
            ts=0;
            delta_I=0;
            delta_E=0;          
        end
    end
 
 % GABA-A ext
 gGABA_ext(i+1)=ggGABA_ext(i)*dt + gGABA_ext(i);
 ggGABA_ext(i+1)=(alpha1_GABA.*alpha2_GABA.*( delta_I.*(1-gGABA_ext(i))./K(alpha1_GABA,alpha2_GABA)-gGABA_ext(i)-(1/alpha1_GABA +1/alpha2_GABA).*ggGABA_ext(i))).*dt +ggGABA_ext(i);
 
% AMPA ext
 gAMPA_ext(i+1)=ggAMPA_ext(i)*dt + gAMPA_ext(i);
 ggAMPA_ext(i+1)=(alpha1_AMPA.*alpha2_AMPA.*( delta_E.*(1-gAMPA_ext(i))./K(alpha1_AMPA,alpha2_AMPA)-gAMPA_ext(i)-(1/alpha1_AMPA +1/alpha2_AMPA).*ggAMPA_ext(i))).*dt + ggAMPA_ext(i);        
 
 % ALGEBRAIC EQUATIONS
 
 % NMDA ext
 gNMDA_ext(i+1)=ggNMDA_ext(i)*dt + gNMDA_ext(i);
 ggNMDA_ext(i+1)=(alpha1_NMDA.*alpha2_NMDA.*( delta_E.*(1-gNMDA_ext(i))./K(alpha1_NMDA,alpha2_NMDA)-gNMDA_ext(i)-(1/alpha1_NMDA +1/alpha2_NMDA).*ggNMDA_ext(i))).*dt +ggNMDA_ext(i);
 
 % Na-P-pump
 Ap=(1/((1+(Koalpha_E/Ko(i)))*(1+(Koalpha_E/Ko(i)))))*(1/((1+(Naialpha_E/Nai_E))*(1+(Naialpha_E/Nai_E))*(1+(Naialpha_E/Nai_E))));
 Ikpump=-2*Imaxsoma_E*Ap;
 INapump=3*Imaxsoma_E*Ap;
 
 % reversal potentials on soma and dendrite 
 % K
 VKe=e0_E*log(Ko(i)/Ki_E);
 % NA
 VNAe=e0_E*log(Nao_E/Nai_E); 
 % CL
 VCL=e0_E*log(Cli(i)/Clo_E);
 % VGABA
 VGABA(i)=(R*Temp/F)*log((Cli(i)+P_Cl_HCO3*HCO3i)./(Clo_E+P_Cl_HCO3*HCO3o))*1000; % VGABA CHANGED!!!
 % VNKCC1
 V_NKCC1=(VKe+VNAe)/2;
 
 % dendrite current
 f_NMDA=1/(1+Mg/3.57*exp(-0.062*VD(i)));
 iDendrite= -gNMDA_max*gNMDA_ext(i)*f_NMDA*(VD(i)-VNMDA) -gGABA_max*gGABA_ext(i)*(VD(i)-VGABA(i)) -gAMPA_max.*gAMPA_ext(i)*(VD(i)-V_AMPA) -G_lD_E*(VD(i)-VCL) -G_kl_E*(VD(i)-VKe) -G_Nal_E*(VD(i)-VNAe) -2.9529*G_NaD_E*m_iNaD(i)^3*h_iNaD(i)*(VD(i)-VNAe) -G_NapD_E*m_iNapD(i)*(VD(i)-VNAe) -G_KCa_E*m_iKCa(i)^2*(VD(i) - VKe) -2.9529*G_Km_E*m_iKm(i)*(VD(i) - VKe) -2.9529*G_HVA_E*m_iHVA(i)^2*h_iHVA(i)*(VD(i)-E_Ca_E) -INapump -Ikpump;
 
 % somatic voltage
 g1_SOMA=gg_kl_E +gg_Nal_E +(2.9529*G_Na_E*m_iNa(i)^3*h_iNa(i)) +(2.9529*G_Kv_E*m_iKv(i));
 g2_SOMA=gg_kl_E*VKe +gg_Nal_E*VNAe +(2.9529*G_Na_E*m_iNa(i)^3*h_iNa(i)*VNAe) +(2.9529*G_Kv_E*m_iKv(i)*VKe) -INapump -Ikpump;

 VSOMA(i)=(VD(i) + (kappa_E*S_Soma_E *g2_SOMA)) / (1+kappa_E*S_Soma_E*g1_SOMA);
 
 % Ikv, POTASSIUM CHANNEL
a_iKv=0.02*(VSOMA(i)-Vbolz_E)/(1-exp(-(VSOMA(i)-Vbolz_E)/9));
b_iKv=-0.002*(VSOMA(i)-Vbolz_E)/(1-exp((VSOMA(i)-Vbolz_E)/9));
tauKvm=1/((a_iKv+b_iKv)*2.9529);
infKvm=a_iKv/(a_iKv+b_iKv);

 % INA, SODIUM CHANNEL 
am_iNa=0.182*(VSOMA(i)-10+35)/(1-exp(-(VSOMA(i)-10+35)/9));
bm_iNa=0.124*(-VSOMA(i)+10-35)/(1-exp(-(-VSOMA(i)+10-35)/9));
ah_iNa=0.024*(VSOMA(i)-10+50)/(1-exp(-(VSOMA(i)-10+50)/5));
bh_iNa=0.0091*(-VSOMA(i)+10-75)/(1-exp(-(-VSOMA(i)+10-75)/5));
tau_m=(1/(am_iNa+bm_iNa))/2.9529;
tau_h=(1/(ah_iNa+bh_iNa))/2.9529;
m_inf_new=am_iNa/(am_iNa+bm_iNa);
h_inf_new=1/(1+exp((VSOMA(i)-10+65)/6.2));

% NaP, D current
minfiNapD = 0.02/(1 + exp(-(VD(i)+42)/5));

% INa D, sodium channel
am_iNaD=0.182*(VD(i)-10+35)/(1-exp(-(VD(i)-10+35)/9));
bm_iNaD=0.124*(-VD(i)+10-35)/(1-exp(-(-VD(i)+10-35)/9));
ah_iNaD=0.024*(VD(i)-10+50)/(1-exp(-(VD(i)-10+50)/5));
bh_iNaD=0.0091*(-VD(i)+10-75)/(1-exp(-(-VD(i)+10-75)/5));
minf_newD = am_iNaD/(am_iNaD+bm_iNaD);
hinf_newD = 1/(1+exp((VD(i)-10+65)/6.2));
tau_mD = (1/(am_iNaD+bm_iNaD))/2.9529;
tau_hD = (1/(ah_iNaD+bh_iNaD))/2.9529;

%%%% iKCa %%%%
minf_iKCa = (48*cai(i)*cai(i)/0.03)/(48*cai(i)*cai(i)/0.03 + 1);
taum_iKCa = (1/(0.03*(48*cai(i)*cai(i)/0.03 + 1)))/4.6555;

%%%% IHVA %%%%
am_iHVA = 0.055*(-27 - VD(i))/(exp((-27-VD(i))/3.8) - 1);
bm_iHVA = 0.94*exp((-75-VD(i))/17);
ah_iHVA = 0.000457*exp((-13-VD(i))/50);
bh_iHVA = 0.0065/(exp((-VD(i)-15)/28) + 1);
tauHVAh = 1/((ah_iHVA+bh_iHVA)*2.9529);
infHVAh = ah_iHVA/(ah_iHVA+bh_iHVA);
tauHVAm = 1/((am_iHVA+bm_iHVA)*2.9529);
infHVAm = am_iHVA/(am_iHVA+bm_iHVA);

%%% IKM %%%%
 am_iKm = 0.001 * (VD(i) + 30) / (1 - exp(-(VD(i) + 30)/9));
 bm_iKm = -0.001 * (VD(i) + 30) / (1 - exp((VD(i) + 30)/9));
 tauKmm = 1/((am_iKm+bm_iKm)*2.9529);
 infKmm = am_iKm/(am_iKm+bm_iKm);

% ION CURRENTS
ICL = G_lD_E*(VD(i)-VCL) +gGABA_max*gGABA_ext(i)*(VD(i)-VGABA(i));
IK = gg_kl_E*(VSOMA(i)-VKe) +G_kl_E*(VD(i)-VKe) +G_KCa_E*m_iKCa(i)*m_iKCa(i)*(VD(i)-VKe) +2.9529*G_Km_E*m_iKm(i)*(VD(i)-VKe) +(2.9529*G_Kv_E*m_iKv(i)*(VSOMA(i)-VKe))/200;

% GLIA
kon=koff_E/(1+exp((Ko(i)-Kothsoma_E)/(-1.15)));
Glia=koff_E*(Bmax_E-Bs(i))/K1n_E -kon/K1n_E*Bs(i)*Ko(i);

%INTEGRATION
VD(i+1) = ((1/Cm_E)*(iDendrite +(VSOMA(i)-VD(i)) / (kappa_E*S_Dend_E)))*dt + VD(i);
m_iNa(i+1) =(-(m_iNa(i)-m_inf_new)/tau_m)*dt + m_iNa(i);
h_iNa(i+1) =(-(h_iNa(i)-h_inf_new)/tau_h)*dt + h_iNa(i);
m_iKv(i+1) =(-(m_iKv(i)-infKvm)/tauKvm)*dt + m_iKv(i);
m_iNaD(i+1) =(-(m_iNaD(i) - minf_newD)/tau_mD)*dt +m_iNaD(i);
h_iNaD(i+1) =(-(h_iNaD(i) - hinf_newD)/tau_hD)*dt +h_iNaD(i);
m_iNapD(i+1)=(-(m_iNapD(i) - minfiNapD)/0.1992)*dt +m_iNapD(i);
m_iKCa(i+1) =(-(1/taum_iKCa)*(m_iKCa(i) - minf_iKCa))*dt + m_iKCa(i);
m_iHVA(i+1) = (-(m_iHVA(i)-infHVAm)/tauHVAm)*dt + m_iHVA(i);
h_iHVA(i+1) = (-(h_iHVA(i)-infHVAh)/tauHVAh)*dt + h_iHVA(i);
m_iKm(i+1) = (-(m_iKm(i)-infKmm)/tauKmm)*dt + m_iKm(i);

% ION CONCENTRATION
Ko(i+1)=(kK_E/F/d_E*(IK +Ikpump +Ikpump +Glia -Ikcc2_E*(VKe-VCL)/((VKe-VCL)+Vhalf_E)) )*dt + Ko(i);
Bs(i+1)=(koff_E*(Bmax_E-Bs(i)) -kon*Bs(i)*Ko(i))*dt + Bs(i);
Cli(i+1)=kCL_E/F*(ICL + Ikcc2_E*(VKe-VCL)/((VKe-VCL)+Vhalf_E) )*dt + Cli(i);
cai(i+1)=(-5.1819e-5* 2.9529*G_HVA_E*m_iHVA(i)^2*h_iHVA(i) * (VD(i) - E_Ca_E)/DCa_E + (0.00024-cai(i))/TauCa_E)*dt + cai(i);     
 
end

%% Calculate the number of spikes after stimulation
V_after_stim=VSOMA((Tend+50)/dt:end);
N_spike(k,p)=length(spike_times(V_after_stim,0.4));

if i*dt>=Tstart-1
    Cl_end(k,p)=Cli(i);       % save the corresponding Cli value, just before the stimulation
end

%%


    end    
end


%% PLOT

%%
figure;

imagesc(X,Y,N_spike);
set(gca,'YDir','normal');
title('Number of spikes after stimulation');
colorbar;
box off;

set(gca,'FontSize',20);             % set the axis with big font
xlabel('Cli_{IN} (mM)');
ylabel('HCO3_{IN} (mM)');

%%