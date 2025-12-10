function HP_Data = heatPump()

    dataPack = controller(); 
    data = jsondecode(dataPack);
    inputVals = humanMachineInterface();
    inputVals = jsondecode(inputVals);
    
    heatLossRate = inputVals.heatPump.heatLoss;
    setTemp = inputVals.heatPump.setTemp;
    COP = inputVals.heatPump.COP;
    outdoorTemp = data.Temperature_Data.Average_Temperatures;
    HP_Time = data.Temperature_Data.Weather_Time_Base;
    HP_Time = datetime(HP_Time, "Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    
    heatLoss = -(heatLossRate.*(setTemp-outdoorTemp))/1000;
    HP_Power = -heatLoss/COP;
    disp(numel(HP_Power))
    disp("HP_ PowerIs")
    %[HP_Time, HP_Power] = stairs(HP_Time,HP_Power);
    
    HP_Data = struct('HP_Power', HP_Power, 'HP_Time_Base', HP_Time);
    
    % figure; plot(HP_Time(1:24), HP_Power(1:24));
    % xlabel('Time');
    % ylabel('Heat Power');
    % title('Heat Loss and Compensating Power from HP');
    % hold on;
    % stairs(HP_Time(1:24), HP_Power(1:24));
    % legend('Power Lost','HP Input Power') 
    
    end