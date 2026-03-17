function inputData = humanMachineInterface()
    global date % This allows findBestDay() to run
    global bestDay
    
    %% Change the following for different simulation results
    % BATTERY SPECS
    inputData.battery.battEnergy = 10; % Intial battery capacity of 10 kWh
    
    % LOCATION SPECS
    inputData.location.lat = 55.38;
    inputData.location.lon = -1.56;
    
    % HEAT PUMP SPECS
    inputData.heatPump.setTemp = 19;
    inputData.heatPump.heatLoss = 335.38;
    inputData.heatPump.COP = 3.66; % Taken from VAILLANT AROTHERM
    inputData.heatPump.highTempTimeOn = '06:00:00';
    inputData.heatPump.highTempTimeOff = '22:30:00';
    inputData.heatPump.hotWaterEnergy = 90*4.18*40/3600; % Litres used * heat capacity * temperature difference / kWh conversion
    inputData.heatPump.HW_Start = 'T11:00:00Z';
    inputData.heatPump.HW_End = 'T15:00:00Z';

    %%APPLIANCE SPECS
    inputData.ApplianceData.Start_Time = 'T02:00:00Z';
    inputData.ApplianceData.End_Time = 'T05:00:00Z';
    inputData.ApplianceData.totalEnergy = 0.67+0.95; % Combined Washing Machine and Dishwasher
    
    % TEST DAY FOR APP
    testDay ='2022-10-27';
    nextDay = '2022-10-28';


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
    
    inputData.PVData.numPanels = 8;
    inputData.PVData.panelArea = 1.7*1;

    
end
