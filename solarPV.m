function PV_Data = solarPV()
%% Today
dataPack = controller();
data = jsondecode(dataPack);
todayPVPower = data.Solar_Data.GTI(1:96);
todayPVTime = data.Solar_Data.Solar_Time_Base(1:96);
todayPVTime = datetime(todayPVTime, "Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');

todayPVData = struct('PV_Power', todayPVPower,'PV_Time_Base', todayPVTime);

%% Next Day

nextPVPower = data.Solar_Data.GTI(49:96);
nextPVTime = data.Solar_Data.Solar_Time_Base(49:96);

nextPVData = struct('PV_Power', nextPVPower, 'PV_Time_Base', nextPVTime);

%% Collate Data

PV_Data = struct('Today_PV_Data', todayPVData, 'Next_Day_PV_Data', nextPVData);

disp(PV_Data.Today_PV_Data);
end
