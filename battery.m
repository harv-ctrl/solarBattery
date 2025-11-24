function batteryData = battery(limbo) % Limbo is sent from controller to specify battery action
% Read data sent fron Controller
   
    dataPack = controller();
    data = jsondecode(dataPack);
    battkWh = data.Battery_Parameters.Energy_Stored;
    cR = data.Battery_Parameters.Charge_Rate;
    t = data.Battery_Parameters.Time_Period;
    dR = data.Battery_Parameters.Discharge_Rate;
    
% Define charging 
    function storedkW = charge(storedkW, cR, t)
        storedkW = storedkW + cR*t;
    end
    
% Define discharging
    function storedkW = discharge(storedkW, dR, t)
        storedkW = storedkW - dR*t;
    end
    if limbo == 1
        battkWh = charge(battkWh, cR, t);
    end
    if limbo == 2
        battkWh = discharge(battkWh, dR, t);
    end
    
% Describe battery status
    function status = battStatus(battkWh)
        if battkWh >= 10
            status = 'Overcharged';
        elseif battkWh >= 9 && battkWh <= 10
            status = 'Fully Charged';
        elseif battkWh >= 1 && battkWh <= 9
            status = append('Current Charge Level: ', string((battkWh./10).*100), '%');
        end
          end
    status = battStatus(battkWh);
    batteryData = struct('Charge_Level', battkWh, 'Status', status);
    
end

