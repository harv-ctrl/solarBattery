function todayTime = solarPV()

%% Predictive Day
dataPack = controller();
data = jsondecode(dataPack);
todayData = data.Solar_Data.GTI(1:24);
todayTime = data.Solar_Data.Solar_Time_Base;

%% Actual Day

end
