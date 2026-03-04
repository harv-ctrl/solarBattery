Shifted_Values = yearPrices2025.Shifted_Value;
Unshifted_Values = yearPrices2025.Unshifted_Value;
Savings = yearSaving2025;
Time = yearPrices2025.Time;
[M,I] = max(Savings); maxTime = Time(I);
[Mi,Ii] = min(Savings); minTime = Time(Ii);
WholeYearSaving = sum(Savings);

Time = datetime(Time,"Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');

%% Shifted Cost
% figure('Color',[0.95 1 1]); 
% subplot(2,1,1);
% plot(Time,Shifted_Values./100, 'g.',Time,Unshifted_Values./100, 'r.'); grid on
% ylabel('Cost (£)');
% xlabel('Time');
% title('Cost of Energy over 2025');
% subplot(2,1,2);
% plot(T,cumsum(Shifted_Values./100),'g',T,cumsum(Unshifted_Values./100),'r'); grid on;
% ylabel('Cost (£)');
% title('Cumulative Cost over 2025');

%% Difference

figure('Color',[0.95 1 1]); 
subplot(1,3,1);
plot(Time,Shifted_Values./100, 'g.',Time,Unshifted_Values./100, 'r.'); grid on
ylabel('Cost (£)');
%xlabel('Time');
title('Cost of Energy over 2025');
legend('Shifted','Unshifted');
subplot(1,3,2);
plot(Time,cumsum(Shifted_Values./100),'g',Time,cumsum(Unshifted_Values./100),'r',Time,cumsum(yearSaving2025)./100,'k'); grid on;
ylabel('Cost (£)')
%xlabel('Time');
title('Cumulative Cost over 2025');
legend('Shifted Cost','Unshifted Cost','Saving');
subplot(1,3,3);
plot(Time,(abs(Shifted_Values-Unshifted_Values)./100),'k.'); grid on;
ylabel('Cost Saving (£)')
%xlabel('Time');
title('Cost Saving over 2025');

%% Years

Years = [2021 2022 2023 2024 2025];

EV(1) = sum(yearPrices2021.Shifted_Value)/100;
EV(2) = sum(yearPrices2022.Shifted_Value)/100;
EV(3) = sum(yearPrices2023.Shifted_Value)/100;
EV(4) = sum(yearPrices2024.Shifted_Value)/100;
EV(5) = sum(yearPrices2025.Shifted_Value)/100;
GV(1) = 1062;
GV(2) = 1828;
GV(3) = 2055;
GV(4) = 1661;
GV(5) = 1760;
Values = [EV; GV];


figure('Color',[0.95 1 1]);
bar(Years,Values);
xlabel('Year')
ylabel('Yearly Cost (£)');
title('Yearly Total Import Cost');
legend('Heat Pump System','Gas Boiler System');
ans = sum(yearSaving2025);
%% Prices of Natural Gas
GIP = table(GasPrices(:,1),GasPrices(:,2),GasPrices(:,3),'VariableNames',{'Imports';'Production';'Year'});

figure; 
plot(GIP.Year,GIP.Imports./1000,'r',GIP.Year,GIP.Production./1000,'b'); grid on;
xlabel('Time');
ylabel('Supply (TWh)')
title('Energy Imports and Production since 2000');
legend('Imports','UK Produced');


