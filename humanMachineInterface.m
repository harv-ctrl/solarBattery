function inputData = humanMachineInterface()
    global date % This allows findBestDay() to run
    global bestDay
    
    %% Change the following for different simulation results
    % BATTERY SPECS
    inputData.battery.battEnergy = 10; % Initial battery capacity: 10 kWh
    inputData.battery.chargeEfficiency = 0.95;    % Charging efficiency: 95%
    inputData.battery.dischargeEfficiency = 0.95; % Discharging efficiency: 95%
    
    % LOCATION SPECS (set to Coventry)
    inputData.location.lat = 52.41;
    inputData.location.lon = -1.51;
    
    % HEAT PUMP SPECS
    inputData.heatPump.setTemp = 19;
    inputData.heatPump.heatLoss = 335.38;
    inputData.heatPump.COP = 3.66; % Taken from VAILLANT AROTHERM
    inputData.heatPump.highTempTimeOn = '06:00:00';
    inputData.heatPump.highTempTimeOff = '22:30:00';
    inputData.heatPump.hotWaterEnergy = 90*4.18*40/3600; % Litres used * heat capacity * temperature difference / kWh conversion
    inputData.heatPump.HW_Start = 'T11:00:00Z';
    inputData.heatPump.HW_End = 'T15:00:00Z';

    % PV SPECS
    inputData.PVData.numPanels = 8;
    inputData.PVData.panelArea = 1.7*1; % Area per panel, m2

    %% APPLIANCE SPECS
    inputData.ApplianceData.Start_Time = 'T02:00:00Z';
    inputData.ApplianceData.End_Time = 'T05:00:00Z';
    inputData.ApplianceData.totalEnergy = 0.67+0.95; % Combined Washing Machine and Dishwasher

    % Additional household electricity: placeholder daily energy, kWh/day
    inputData.ApplianceData.fridgeFreezerEnergy = 0.8;
    inputData.ApplianceData.lightingEnergy = 0.5;
    inputData.ApplianceData.cookingEnergy = 1.8;
    inputData.ApplianceData.electronicsEnergy = 1.0;
    inputData.ApplianceData.otherEnergy = 0.4; % Excludes categories above

    % Combined additional daily energy, kWh/day
    inputData.ApplianceData.otherDailyEnergy = ...
        inputData.ApplianceData.fridgeFreezerEnergy ...
        + inputData.ApplianceData.lightingEnergy ...
        + inputData.ApplianceData.cookingEnergy ...
        + inputData.ApplianceData.electronicsEnergy ...
        + inputData.ApplianceData.otherEnergy;
    
    % Placeholder usage windows: [start hour, end hour]
    % Each row represents one window.
    inputData.ApplianceData.lightingHours = [6  8;
                                             17 23];
    inputData.ApplianceData.cookingHours = [7  8;
                                            12 13;
                                            18 20];
    inputData.ApplianceData.electronicsHours = [17 23];

    % TEST DAY FOR APP (This dude loves Oct 27th & 28th 2022)
    %From my understanding, it uses the next day as the day thats shown in
    %the app. 
    testDay ='2026-01-01';
    nextDay = '2026-01-02';


    %% INDIVIDUAL TEST DAY SPEC (FOR APP)
        

    % Detect if findBestDay() is running
    if  bestDay == true
        inputData.TestCase.begin_date = date.start;
        inputData.TestCase.end_date = date.end;
        inputData.TestCase.begin_date_short = date.ss;
        inputData.TestCase.end_date_short = date.se;
    else % Otherwise apply example day
        inputData.TestCase.begin_date = append(testDay,'T00:00:00Z');
        inputData.TestCase.end_date = append(nextDay,'T23:30:00Z');
        inputData.TestCase.begin_date_short = testDay;
        inputData.TestCase.end_date_short = nextDay;
    end
end
