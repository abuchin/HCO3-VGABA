Cli=1:1:20;
HCO3i=1:1:30;

VGABA=zeros(max(Cli),max(HCO3i));

e0_E=26.6393;   % kT/F, in Nernst equation
HCO3o=26;       % mM
Clo_E=130;      % mM


for i=1:1:max(Cli)
    for j=1:1:max(HCO3i)
   VGABA(i,j)=e0_E*log((4*Cli(i)+HCO3i(j))./(4*Clo_E+HCO3o));
    end
end


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