function inputData = humanMachineInterface()
    global date
    inputData.battery.battEnergy = 10; % Intial battery capacity of 10 kWh
    
    inputData.location.lat = 55.38;
    inputData.location.lon = -1.56;

    inputData.heatPump.setTemp = 19;
    inputData.heatPump.heatLoss = 335.38;
    inputData.heatPump.COP = 3.14; % Taken from VAILLANT AROTHERM
    
    % startdate = datetime('2025-01-1T00:00:00Z','InputFormat','uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    % enddate = datetime('2025-01-1T23:30:00Z','InputFormat','uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    % startdateshort = datetime('2025-01-1','Format','uuuu-MM-dd','TimeZone','UTC');
    % enddateshort = datetime('2025-01-2','Format','uuuu-MM-dd','TimeZone','UTC');
    % %disp(startdate);

    % inputData.TestCase.begin_date = '2025-04-6T00:00:00Z';
    % inputData.TestCase.end_date = '2025-04-7T23:30:00Z';
    % inputData.TestCase.begin_date_short = '2025-04-6';
    % inputData.TestCase.end_date_short = '2025-04-7';
    
    inputData.TestCase.begin_date = date.start;
    inputData.TestCase.end_date = date.end;
    inputData.TestCase.begin_date_short = date.ss;
    inputData.TestCase.end_date_short = date.se;
  
  
    inputData.PVData.numPanels = 8;
    inputData.PVData.panelArea = 1.7*1;

    inputData.ApplianceData.Start_Time = 'T02:00:00Z';
    inputData.ApplianceData.End_Time = 'T05:00:00Z';
    inputData.ApplianceData.totalPower = 0.67+0.95; % Combined Washing Machine and Dishwasher
           
    inputData = jsonencode(inputData);
    
end
