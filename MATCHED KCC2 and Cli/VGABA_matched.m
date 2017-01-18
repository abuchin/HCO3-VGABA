%% Plot VGABA as a funciton of Cli, HCO3i

Cli=1:1:30;
HCO3i=1:1:30;

VGABA=zeros(length(Cli),length(HCO3i));

T=310;    
R=8.3;
F=96000;

HCO3o=25;       % mM 26
Clo_E=124.8;      % mM 130

P_Cl_HCO3=0.2;

for i=1:1:length(Cli)
    for j=1:1:length(HCO3i)
        VGABA(i,j)=(R*T/F)*log((Cli(i)+P_Cl_HCO3*HCO3i(j))./(Clo_E+P_Cl_HCO3*HCO3o))*1000;  % to get mV
    end
end

figure
imagesc(VGABA')
title('E_{GABA}')
xlabel('Cl_{IN}^{-} (mM)')
ylabel('HCO3_{IN}^{-} (mM)');
set(gca,'FontSize',20);             % set the axis with big font
set(gca,'YDir','normal');
box off
colormap('jet');
colorbar;

% Check VGABA difference in the key points

VGABA(4,30)
VGABA(10,15)

VGABA(4,30) -VGABA(10,15)

%%



%% VGABA and the number of spikes
figure;

% plot VGABA
yyaxis left
plot(1:30,VGABA(:,15),1:30,VGABA(:,30));
xlabel('[Cl^-_i]')
ylabel('E_{GABA} (mV)')

% plot the spikes
yyaxis right
plot(1:30,VS(15,1:30),1:20,VS(30,1:30));
ylabel('Spikes after HFS')

%%