function E_PROF = energyOptimiser()

% Get Data
getPowerRequirement()


end

function powerReq = getPowerRequirement()
    dataPack = controller();
    data = jsondecode(dataPack);

    HP_Data = heatPump();
    
    PV_Data = solarPV();
    
    HP_Power = HP_Data.HP_Power;
    HP_Time = HP_Data.HP_Time_Base;
    
    PV_Time = PV_Data.Today_PV_Data.PV_Time_Base;
    PV_Power = PV_Data.Today_PV_Data.PV_Power/1000;

    EC_Time = data.Energy_Data.Energy_Time_Base;
    EC_Time = datetime(EC_Time, "Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    EC_Price = data.Energy_Data.Energy_Prices;
        
    T_HP = timetable(HP_Time, HP_Power);
    T_PV = timetable(PV_Time, PV_Power);
    T_EC = timetable(EC_Time, EC_Price);
    
    T1 = join(T_EC,T_HP);
    T = join(T1, T_PV);
    
    
    
    % plot(HP_Time, -powerReq, 'r');
    % xlabel('Time');
    % ylabel('Energy Used (kW)');
    % title('Power Requirement for Home');
    % ylim([0 1]);
end