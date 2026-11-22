function AP_Data = homeAppliances(data, input)
if nargin < 2
    input = humanMachineInterface();
end

if nargin < 1
    data = testController();
end
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
    % Other energy considerations
    washingDishwasherPower = AP_Power; % copies the complete profile over

    fridgeFreezerPower = dailyDemandProfile(time, ...
        input.ApplianceData.fridgeFreezerEnergy, [0 24]);

    lightingPower = dailyDemandProfile(time, ...
        input.ApplianceData.lightingEnergy, ...
        input.ApplianceData.lightingHours);

    cookingPower = dailyDemandProfile(time, ...
        input.ApplianceData.cookingEnergy, ...
        input.ApplianceData.cookingHours);

    electronicsPower = dailyDemandProfile(time, ...
        input.ApplianceData.electronicsEnergy, ...
        input.ApplianceData.electronicsHours);

    otherPower = dailyDemandProfile(time, ...
        input.ApplianceData.otherEnergy, [0 24]);

    AP_Power = washingDishwasherPower...
        + fridgeFreezerPower ...
        + lightingPower ...
        + cookingPower ...
        + electronicsPower ...
        + otherPower;

    AP_Energy = sum(AP_Power)*0.5;
    % Compile output power profile
    AP_Data = struct('AP_Power',AP_Power,'AP_Energy',AP_Energy,'AP_Time',time);
    AP_Data.washingDishwasherPower = washingDishwasherPower;
    AP_Data.fridgeFreezerPower = fridgeFreezerPower;
    AP_Data.lightingPower = lightingPower;
    AP_Data.cookingPower = cookingPower;
    AP_Data.electronicsPower = electronicsPower;
    AP_Data.otherPower = otherPower;
end
function power = dailyDemandProfile(time, dailyEnergy, windows)
hourOfDay = hours(timeofday(time(:)));
active = false(size(hourOfDay));

for k = 1:size(windows, 1)
    active = active | ...
        (hourOfDay >= windows(k,1) & hourOfDay < windows(k,2));
end

activeHours = sum(active)*0.5;

assert(activeHours > 0, ...
    'A household demand profile has no active half-hours.');

power = zeros(size(hourOfDay));
power(active) = dailyEnergy/activeHours;
end