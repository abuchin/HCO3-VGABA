%% Plot VGABA as a funciton of Cli, HCO3i

Cli=1:1:30;
HCO3i=1:1:30;

VGABA=zeros(length(Cli),length(HCO3i));

e0_E=26.6393;   % RT/F, in Nernst equation

T=36+273.15;    
R=8.314;
F=96485.332;

HCO3o=26;       % mM 26
Clo_E=150;      % mM 130

alpha_beta=0.85;
V_shift=-24;

for i=1:1:length(Cli)
    for j=1:1:length(HCO3i)
        VGABA(i,j)=V_shift+(R*T/F)*log((Cli(i)+alpha_beta*HCO3i(j))./(Clo_E+alpha_beta*HCO3o))*1000;  % to get mV
    end
end

figure
imagesc(VGABA')
title('V_{GABA}')
xlabel('Cl_{IN}^{-} (mM)')
ylabel('HCO3_{IN}^{-} (mM)');
set(gca,'FontSize',20);             % set the axis with big font
set(gca,'YDir','normal');
box off
colormap('jet');
colorbar;

% Check VGABA difference in the key points

VGABA(8,30)
VGABA(14,15)

VGABA(8,30) -VGABA(14,15)

%%


%% Plot VGABA as a function of alpha, beta

Cli=8;          % mM
HCO3i=30;        % mM

HCO3o=26;        % mM 6
Clo_E=150;       % mM 130

Temp=23+273.15;      % real temperature correction
R=8.314;
F=96485.332;

alpha_lim=10;
beta_lim=10;
alpha_step=1;
beta_step=1;
V_GABA=zeros(alpha_lim,beta_lim);


for alpha=1:1:(alpha_lim)/alpha_step
    for beta=1:1:(beta_lim)/beta_step
        V_GABA(alpha,beta)=(R*Temp/F)*log((alpha*Cli+beta*HCO3i)./(alpha*Clo_E+beta*HCO3o))*1000;
    end
end

figure
imagesc(V_GABA');
set(gca,'Fontsize',20)
colorbar;
title('V_{GABA}')
xlabel('alpha (Cli)')
ylabel('beta (HCO3i)')
set(gca,'YDir','normal');

%%

%% Plot VGABA as a funciton of Cli, HCO3i

Cli=1:1:30;
HCO3i=1:1:30;

VGABA=zeros(length(Cli),length(HCO3i));

e0_E=26.6393;   % RT/F, in Nernst equation

T=23+273.15;    
R=8.314;
F=96485.332;

HCO3o=80;       % mM 26
Clo_E=250;      % mM 130


for i=1:1:length(Cli)
    for j=1:1:length(HCO3i)
    VGABA(i,j)=(R*T/F)*log((4*Cli(i)+3*HCO3i(j))./(4*Clo_E+3*HCO3o))*1000;  % to get mV
    end
end


figure
imagesc(VGABA')
title('V_{GABA}')
xlabel('Cl_{IN} (mM)')
ylabel('HCO3_{IN} (mM)');
set(gca,'FontSize',20);             % set the axis with big font
set(gca,'YDir','normal');
box off
colormap('jet');
colorbar;
%%

%%





%% VGABA and the number of spikes

figure;

% plot VGABA
yyaxis left
plot(1:20,VGABA(:,15),1:20,VGABA(:,30));
xlabel('[Cl^-_i]')
ylabel('E_{GABA} (mV)')

% plot the spikes
yyaxis right
plot(1:20,VS(15,1:20),1:20,VS(30,1:20));
ylabel('Spikes after HFS')

%%