function Total = calculateEnergy()  
    % Very simple function! Gets total energy used
    HP_Data = heatPump();
    PV_Data = solarPV();
    AP_Data = homeAppliances();
    Total = HP_Data.HP_Energy-PV_Data.PV_Energy+AP_Data.AP_Energy;
end
