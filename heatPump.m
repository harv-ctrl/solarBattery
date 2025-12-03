function pumpUsage = heatPump(setTemp)

    dataPack = controller(); 
    data = jsondecode(dataPack);
    inputVals = humanMachineInterface();
    inputVals = jsondecode(inputVals);
    
    heatLossRate = inputVals.heatPump.heatLoss;
    setTemp = inputVals.heatPump.setTemp;
    COP = inputVals.heatPump.COP;
    outdoorTemp = data.Temperature_Data.Average_Temperatures;
    tempTimeBase = data.Temperature_Data.Weather_Time_Base;
    tempTimeBase = datetime(tempTimeBase, "Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    
    heatLoss = -(heatLossRate.*(setTemp-outdoorTemp))/1000;
    pumpUsage = -heatLoss/COP;

    figure; plot(tempTimeBase(1:24), heatLoss(1:24));
    xlabel('Time');
    ylabel('Heat Power');
    title('Heat Loss and Compensating Power from HP');
    hold on;
    stairs(tempTimeBase(1:24), pumpUsage(1:24));
    legend('Power Lost','HP Input Power')
   
    
end