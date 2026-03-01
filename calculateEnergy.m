function EA = calculateEnergy()  
    % Very simple function! Calls HP and gets total energy used
    HP_Data = heatPump();
    EA = sum(HP_Data.HP_Power(1:48))*0.5;
end
