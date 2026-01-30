function inputData = humanMachineInterface()

    inputData.battery.battEnergy = 10; % Intial battery capacity of 10 kWh
    
    inputData.location.lat = 55.38;
    inputData.location.lon = -1.56;

    inputData.heatPump.setTemp = 19;
    inputData.heatPump.heatLoss = 220;
    inputData.heatPump.COP = 3.43; % Taken from Samsung HP website
    
    inputData.winterTestCase.begin_date = {'2026-01-01T00:00:00Z'};
    inputData.winterTestCase.end_date = {'2026-01-02T23:30:00Z'};
    inputData.winterTestCase.begin_date_short = {'2026-01-01'};
    inputData.winterTestCase.end_date_short = {'2026-01-02'};

    inputData.summerTestCase.begin_date = {'2025-06-20T00:00:00Z'};
    inputData.summerTestCase.end_date = {'2025-06-21T23:30:00Z'};
    inputData.summerTestCase.begin_date_short = {'2025-06-20'};
    inputData.summerTestCase.end_date_short = {'2025-06-21'};
    
    inputData.PVData.numPanels = 8;
    inputData.PVData.panelArea = 1.7*1;
           
    inputData = jsonencode(inputData);
end
