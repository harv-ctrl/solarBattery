function AP_Data = homeAppliances()
    % Gather data
    input = humanMachineInterface();
    data = testController();

    % Convert start and end specified times to datetime
    ST = append(input.TestCase.begin_date_short,input.ApplianceData.Start_Time);
    ET = append(input.TestCase.begin_date_short,input.ApplianceData.End_Time);
    Start_Time = datetime(ST,"Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    End_Time = datetime(ET,"Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    
    % Allocate time for appliance use
    ApplPower = input.ApplianceData.totalEnergy./3;
    AP_Power = zeros(numel(data.Solar_Data.Solar_Time_Base),1);    
    for i = 1:numel(data.Solar_Data.Solar_Time_Base)
        time(i,1) = datetime(data.Solar_Data.Solar_Time_Base(i),"Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
        if time(i,1) >= Start_Time
            if time(i,1) < End_Time
                AP_Power(i,1) = ApplPower;
            else
                AP_Power(i,1) = 0;
            end
        else
            AP_Power(i,1) = 0;
        end
    end
    AP_Energy = sum(AP_Power)*0.5;
    % Compile output power profile
    AP_Data = struct('AP_Power',AP_Power,'AP_Energy',AP_Energy,'AP_Time',time);
end
