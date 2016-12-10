
%%

Cli=8;          % mM
HCO3i=30;        % mM

HCO3o=26;        % mM 6
Clo_E=150;       % mM 130

Temp=23+273.15;      % real temperature correction
R=8.314;
F=96485.332;

%VGABA=(R*Temp/F)*log((4*Cli+1*HCO3i)./(4*Clo_E+1*HCO3o))*1000

%%

%% scan for all VGABA values

V_GABA=zeros(100,100);

for alpha=1:1:100
    for beta=1:1:100
        V_GABA(alpha,beta)=(R*Temp/F)*log((alpha*Cli+beta*HCO3i)./(alpha*Clo_E+beta*HCO3o))*1000;
    end
end

imagesc(V_GABA);
colorbar;
set(gca,'YDir','normal');

%%