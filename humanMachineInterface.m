function inputVals = humanMachineInterface()
    inputVals.battery.cR = 2; % Charge rate of 2kW
    inputVals.battery.t = 0.5; %Time base for charge/discharge
    inputVals.battery.dR = 2; % Discharge rate of 2kW
    inputVals.battery.mode = 1; % 1 = charge, 2 = discharge, 3 = hold steady
    inputVals.battery.battkWh = 10; % Intial battery capacity of 10 kWh
    
    inputVals.location.lat = 55.2;
    inputVals.location.lon = 0;

    inputVals.heatPump.setTemp = 19;
    inputVals.heatPump.heatLoss = 220;
    inputVals.heatPump.COP = 3.43; % Taken from Samsung HP website
    inputVals = jsonencode(inputVals);
end
