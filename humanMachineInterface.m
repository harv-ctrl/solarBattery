function inputData = humanMachineInterface()
    global date % This allows findBestDay() to run

    %% BATTERY SPECS
    inputData.battery.battEnergy = 10; % Intial battery capacity of 10 kWh
    
    %% LOCATION SPECS
    inputData.location.lat = 55.38;
    inputData.location.lon = -1.56;
    
    %% HEAT PUMP SPECS
    inputData.heatPump.setTemp = 19;
    inputData.heatPump.heatLoss = 335.38;
    inputData.heatPump.COP = 3.66; % Taken from VAILLANT AROTHERM
    inputData.heatPump.highTempTimeOn = '06:00:00';
    inputData.heatPump.highTempTimeOff = '22:30:00';
    inputData.heatPump.hotWater = 90*4.18*40/3600; % Litres used * heat capacity * temperature difference / kWh conversion
    inputData.heatPump.HW_Start = 'T11:00:00Z';
    inputData.heatPump.HW_End = 'T15:00:00Z';

    %% INDIVIDUAL TEST DAY SPEC (FOR APP)
        testDay ='2025-10-27';
        nextDay = '2025-10-28';

    % % Detect if findBestDay() is running
    % try 
    %     inputData.TestCase.begin_date = date.start;
    %     inputData.TestCase.end_date = date.end;
    %     inputData.TestCase.begin_date_short = date.ss;
    %     inputData.TestCase.end_date_short = date.se;
    % catch % Otherwise apply example day
    %     inputData.TestCase.begin_date = append(testDay,'T00:00:00Z');
    %     inputData.TestCase.end_date = append(nextDay,'T23:30:00Z');
    %     inputData.TestCase.begin_date_short = testDay;
    %     inputData.TestCase.end_date_short = nextDay;
    % end
    inputData.TestCase.begin_date = append(testDay,'T00:00:00Z');
    inputData.TestCase.end_date = append(nextDay,'T23:30:00Z');
    inputData.TestCase.begin_date_short = testDay;
    inputData.TestCase.end_date_short = nextDay;
  
    inputData.PVData.numPanels = 8;
    inputData.PVData.panelArea = 1.7*1;

    %% APPLIANCE SPECS
    inputData.ApplianceData.Start_Time = 'T02:00:00Z';
    inputData.ApplianceData.End_Time = 'T05:00:00Z';
    inputData.ApplianceData.totalPower = 0.67+0.95; % Combined Washing Machine and Dishwasher
    
end
