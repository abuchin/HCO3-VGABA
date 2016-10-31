
nT_after_stim=Tst/dt;

%%

% voltage after stimulation
V_after_stim=VSOMA(Tst/dt:end);

% constant value
V_last(1:length(V_after_stim))=VSOMA(end);

% plot the difference 

figure
plot(V_after_stim-V_last)
title('Voltage difference')
xlabel('Time (ms)')
ylabel('Voltage (mV)')
set(gca,'FontSize',20);             % set the axis with big font
box off

display('Area under the curve in V/s')
trapz(V_after_stim-V_last)
