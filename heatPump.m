function HP_Data = heatPump()
    data = testController(); 
    inputData = humanMachineInterface();
    %% Heating Requirement   
    % From HMI
    heatLossRate = inputData.heatPump.heatLoss;
    setHighTemp = inputData.heatPump.setTemp;
    setLowTemp = setHighTemp-2;
    COP = inputData.heatPump.COP;
    highTempTimeOn = inputData.heatPump.highTempTimeOn;
    highTempTimeOff = inputData.heatPump.highTempTimeOff;

    % From Controller
    outdoorTemp = data.Temperature_Data.Average_Temperatures;
    HP_Time = data.Temperature_Data.Weather_Time_Base;
    HP_Time = datetime(HP_Time, "Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    
    % Allocation of Energy Requirement for High and Low periods
    TOD = timeofday(HP_Time);
    period1 = (TOD<=duration(highTempTimeOn)).*(heatLossRate.*(setLowTemp-outdoorTemp))/1000;
    period2 = ((TOD>duration(highTempTimeOn)).*(TOD<=duration(highTempTimeOff))).*(heatLossRate.*(setHighTemp-outdoorTemp))/1000;
    period3 = (TOD>duration(highTempTimeOff)).*(heatLossRate.*(setLowTemp-outdoorTemp))/1000;      
    heatReq = period1 + period2 + period3;

    % Setting limits for HP Delivery
    HP_Power = heatReq/COP;
    HP_Power = max(HP_Power,0);
    HP_Power = min(HP_Power,5);
    HP_Power(outdoorTemp > 17) = 0; % HP does not operate close to set temp
    %% Hot Water Usage
    HW_Power_Draw = (inputData.heatPump.hotWaterEnergy)/4; % Half-hourly usage, could be improved
    ST = append(inputData.TestCase.begin_date_short,inputData.heatPump.HW_Start);
    ET = append(inputData.TestCase.begin_date_short,inputData.heatPump.HW_End);
    Start_Time = datetime(ST,"Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    End_Time = datetime(ET,"Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    for i = 1:numel(HP_Time)
        if HP_Time(i) >= Start_Time && HP_Time(i) < End_Time
            HP_Power(i) = HP_Power(i) + (HW_Power_Draw/COP);
        end
    end

    % Energy
    HP_Energy = sum(HP_Power)*0.5 ;
%% Collate Data    
    HP_Data = struct('HP_Power', HP_Power,'HP_Energy',HP_Energy, 'HP_Time_Base', HP_Time);
end