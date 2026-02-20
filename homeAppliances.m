function AP_Data = homeAppliances()
    input = jsondecode(humanMachineInterface());
    data = jsondecode(testController());
    ST = append(input.TestCase.begin_date_short,input.ApplianceData.Start_Time);
    ET = append(input.TestCase.begin_date_short,input.ApplianceData.End_Time);
    Start_Time = datetime(ST,"Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    End_Time = datetime(ET,"Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    ApplPower = input.ApplianceData.totalPower./6;
    disp(End_Time)
    
    for i = 1:numel(data.Solar_Data.Solar_Time_Base)
    time(i,1) = datetime(data.Solar_Data.Solar_Time_Base(i),"Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
        if time(i,1) >= Start_Time
            if time(i,1) < End_Time
                prof(i,1) = ApplPower;
            else
                prof(i,1) = 0;
            end
        else
            prof(i,1) = 0;
        end
    end

    AP_Data = struct('AP_Power',prof,'AP_Time',time);
    AP_Data = jsonencode(AP_Data);
end
