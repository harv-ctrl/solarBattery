%% Figure 2.1.1 
bungs = 2.48;
flats = 6.31;
terr = 6.99;
semi = 6.36;
detach = 4.33;
others = 0.05+0.12+0.19;
x = {'Bungalows', 'Flats & Maisonettes' 'Terraced' 'Semi-Detached' 'Detached' 'Others'};
figure;
bar(x,[bungs flats terr semi detach others],'EdgeColor','blue','FaceColor','#add8e6');
xlabel("Property Type");
ylabel("Number of Properties (millions)");
title("Property Distribution in England and Wales");
ylim([0 7.2]);

%% Figure 2.1.2
try
    load systemaveragepriceofgasdataset050226 
    load electricitypricesdataset050226
catch
end
time = electricitypricesdataset050226S4.Month;
gas_prices = systemaveragepriceofgasdataset050226S4.SAPMonthlyAverage;
elec_prices = electricitypricesdataset050226S4.MonthlyAverage;
figure;
plot(time,gas_prices,'r',time,elec_prices,'g');
xlabel("Date");
ylabel("Price per kWh (pence)");
title("Average System Price of Gas and Electricity between Jan 2020 and Jan 2026");
legend("Gas Price","Electricity Price");
%% Figure 2.2.1
try
    load Heat_pump_deployment_quarterly_statistics_United_Kingdom_2025_Q3
catch
end
times = datetime(HeatpumpdeploymentquarterlystatisticsUnitedKingdom2025Q3S6.InstallationQuarternote4,"Format","yyyy QQQ");
plot(times,HeatpumpdeploymentquarterlystatisticsUnitedKingdom2025Q3S6.GovernmentsupportedHeatPumpInstallationsAllTechnologies./1000,'r');
hold on;
plot(times,ones(size(times)).*150,'b.');
title("Installations of Heat Pumps compared to 2028 Target");
ylabel("Heat Pump Installations (1000s)")
xlabel("Time")
ylim([0 155])
%% Figure 2.2.2
try
    load systemaveragepriceofgasdataset050226 
    load electricitypricesdataset050226
catch
end
time = electricitypricesdataset050226S4.Month;
gas_prices = systemaveragepriceofgasdataset050226S4.SAPMonthlyAverage;
elec_prices = electricitypricesdataset050226S4.MonthlyAverage;
figure;
plot(time,elec_prices./gas_prices,'b');
xlabel("Time");
ylabel("Ratio of Electricity to Gas Price");
title("Relative Price of Electricity to Gas");
ylim([1.8 6.5])