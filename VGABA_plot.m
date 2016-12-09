%%

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
%%

%%
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

% scale the colormap
cmin=-120;
cmax=-40;
%caxis([cmin cmax]);

%%

%% Check VGABA difference in the key points

VGABA(8,30) -VGABA(14,15)

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