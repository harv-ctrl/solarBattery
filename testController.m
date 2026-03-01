function data = testController()
    % Gather initial values for API queries
    inputData = humanMachineInterface();

    %% SECTION HERE TO REDUCE NUMBER OF OPEN-METEO CALLS (I'm running out)
    global allData 
    lat = inputData.location.lat;
    lon = inputData.location.lon;
    beg = datetime(inputData.TestCase.begin_date_short,"Format","uuuu-MM-dd",'TimeZone','UTC');
    fin = datetime(inputData.TestCase.end_date_short, "Format","uuuu-MM-dd",'TimeZone','UTC');
    weatherSite = append('https://archive-api.open-meteo.com/v1/archive?latitude=',string(lat),'&longitude=',string(lon),'&start_date=',string(beg),'&end_date=',string(fin),'&hourly=temperature_2m&hourly=global_tilted_irradiance&tilt=40');
    allData = webread(weatherSite);
    %% END OF ADDED SECTION
    
    tempData = getTestWeather(); % Loading Average Temperature Data from Open-Meteo.com
    solarData = getTestPVPower(); % Loading Solar Data from Open-Meteo,com
    energyCosts = getTestEnergyCost(); % Loading Octopus Energy Agile Data
    
    % Create data package for components
    data = struct('Temperature_Data', tempData, 'Solar_Data', solarData, 'Energy_Data', energyCosts);
end
%% Locals
function energyCosts = getTestEnergyCost()
    inputData = humanMachineInterface();
    beg = inputData.TestCase.begin_date;
    fin = inputData.TestCase.end_date;
    agileAPIImport = append('https://api.octopus.energy/v1/products/AGILE-18-02-21/electricity-tariffs/E-1R-AGILE-18-02-21-C/standard-unit-rates/?period_from=',string(beg),'&period_to=',string(fin));
    agileAPIExport = append('https://api.octopus.energy/v1/products/AGILE-OUTGOING-19-05-13/electricity-tariffs/E-1R-AGILE-OUTGOING-19-05-13-A/standard-unit-rates/?period_from=',string(beg),'&period_to=',string(fin));
   
    energyImportData = webread(agileAPIImport);
    energyExportData = webread(agileAPIExport);
    count = energyImportData.count;
    for i = 1:count
        energyImportCosts(i,1) = energyImportData.results(i).value_inc_vat;
        energyExportCosts(i,1) = energyExportData.results(i).value_inc_vat;
        time{i,1} = energyImportData.results(i).valid_from;
        
    end
    time = datetime(time, 'InputFormat','uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    energyImportCosts = struct('Energy_Import_Prices', flip(energyImportCosts), 'Energy_Import_Time_Base', flip(time));
    energyExportCosts = struct('Energy_Export_Prices',flip(energyExportCosts),'Energy_Export_Time_Base',flip(time));
    energyCosts = struct('Energy_Import_Costs',energyImportCosts,'Energy_Export_Costs', energyExportCosts);
end

function solarTestData = getTestPVPower()
    global allData
    solarData = allData;

    avGTI = double(solarData.hourly.global_tilted_irradiance);
    solarTimeString = solarData.hourly.time;
    solarTime = datetime(solarTimeString, 'InputFormat','uuuu-MM-dd''T''HH:mm','TimeZone','UTC');
    
    % Interpolate data for half hourly resolution
    xq = (solarTime(1):(1/48):solarTime(numel(solarTime)))';
    avGTI = interp1(solarTime, avGTI, xq);
    solarTime = xq;
    
    solarTestData = struct('GTI', avGTI, 'Solar_Time_Base', solarTime);
end

function tempData = getTestWeather()
    global allData
    inputData = humanMachineInterface();
            
    for i = 1:numel(allData.hourly.time)
        averageTemps(i,1) = allData.hourly.temperature_2m(i);
        API_Time(i,1) = allData.hourly.time(i);
        converted_API_Time(i,1) = datetime(API_Time(i,1), "Format",'uuuu-MM-dd''T''HH:mm', 'TimeZone', 'UTC');
    end
    
    beg = datetime(inputData.TestCase.begin_date, 'InputFormat','yyyy-MM-dd''T''HH:mm:ss''Z', 'TimeZone', 'UTC');
    fin = datetime(inputData.TestCase.end_date, 'InputFormat','yyyy-MM-dd''T''HH:mm:ss''Z', 'TimeZone', 'UTC');
    % Interpolate data for half hourly resolution
    xq = beg:1/48:fin;
    averageTemps = interp1(converted_API_Time, averageTemps, xq);
    API_Time = xq;
    tempData = struct('Average_Temperatures', averageTemps, 'Weather_Time_Base', API_Time);
end




