function HP_Data = heatPump()

    dataPack = testController(); 
    data = jsondecode(dataPack);
    inputData = humanMachineInterface();
    inputData = jsondecode(inputData);
    
    heatLossRate = inputData.heatPump.heatLoss;
    setTemp = inputData.heatPump.setTemp;
    COP = inputData.heatPump.COP;
    outdoorTemp = data.Temperature_Data.Average_Temperatures;
    HP_Time = data.Temperature_Data.Weather_Time_Base;
    HP_Time = datetime(HP_Time, "Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    
    heatLoss = -(heatLossRate.*(setTemp-outdoorTemp))/1000;
    HP_Power = -heatLoss/COP;
    for i = 1:size(HP_Power)
        if HP_Power(i) < 0
            HP_Power(i) = 0;
        end
    end
%% Collate Data    
    HP_Data = struct('HP_Power', HP_Power, 'HP_Time_Base', HP_Time);
    HP_Data = jsonencode(HP_Data);
        end