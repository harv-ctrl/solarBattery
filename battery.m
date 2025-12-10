function battData = battery() % Limbo is sent from controller to specify battery action
% Read data sent fron Controller
   
    dataPack = controller();
    data = jsondecode(dataPack);

    inputVals = humanMachineInterface();
    inputVals = jsondecode(inputVals);

% Read data from heatPump and PV to discharge


    battEnergy = inputVals.battery.battEnergy;

    getPowerRequirement();






% Read data to make prediction about energy usage for next day

    
end


function getPowerRequirement()
    HP_Data = heatPump();
    
    PV_Data = solarPV();
    
    HP_Power = HP_Data.HP_Power;
    HP_Time = HP_Data.HP_Time_Base;
    
    PV_Time = PV_Data.Today_PV_Data.PV_Time_Base;
    PV_Power = PV_Data.Today_PV_Data.PV_Power/1000;
    
    
    T_HP = timetable(HP_Time, HP_Power);
    T_PV = timetable(PV_Time, PV_Power);
    T = join(T_HP,T_PV);
    powerReq = T.PV_Power-T.HP_Power;
    
    plot(HP_Time, -powerReq, 'r');
    xlabel('Time');
    ylabel('Energy Used (kW)');
    title('Power Requirement for Home');
    ylim([0 1]);

end