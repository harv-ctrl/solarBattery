function batteryData = battery(mode) % Limbo is sent from controller to specify battery action
% Read data sent fron Controller
   
    dataPack = controller();
    data = jsondecode(dataPack);
    battkWh = data.Battery_Parameters.Energy_Stored;
    cR = data.Battery_Parameters.Charge_Rate;
    t = data.Battery_Parameters.Time_Period;
    dR = data.Battery_Parameters.Discharge_Rate;
    

    
end

