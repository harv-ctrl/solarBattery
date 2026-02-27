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
    HPS = numel(HP_Power);
    for i = 1:HPS
        if HP_Power(i) < 0
            HP_Power(i) = 0;
        end
        if HP_Power(i) > 5
            HP_Power(i) = 5;
        end
    end
%% Collate Data    
    HP_Data = struct('HP_Power', HP_Power, 'HP_Time_Base', HP_Time);
    HP_Data = jsonencode(HP_Data);
        end