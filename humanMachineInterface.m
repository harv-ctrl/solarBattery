function inputVals = humanMachineInterface()

    inputVals.battery.battEnergy = 10; % Intial battery capacity of 10 kWh
    
    inputVals.location.lat = 55.2;
    inputVals.location.lon = 0;

    inputVals.heatPump.setTemp = 19;
    inputVals.heatPump.heatLoss = 220;
    inputVals.heatPump.COP = 3.43; % Taken from Samsung HP website
    inputVals = jsonencode(inputVals);
end
