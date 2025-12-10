function battData = battery() % Limbo is sent from controller to specify battery action
% Read data sent fron Controller
   
    dataPack = controller();
    data = jsondecode(dataPack);

    inputVals = humanMachineInterface();
    inputVals = jsondecode(inputVals);

% Read data from heatPump and PV to discharge


    battEnergy = inputVals.battery.battEnergy;

% Read data to make prediction about energy usage for next day
    [battData, ~, ~] = energyOptimiser();
    
end


