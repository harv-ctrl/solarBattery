function testDataPack = testController()
% Receive Data

    inputData = humanMachineInterface();
    inputData = jsondecode(inputData);

% Run APIs

    tempData = getTestWeather(); % Loading Average Temperature Forecast from OpenWeatherMap.org
    
    solarData = getTestPVPower(); % Loading Solar Forecast
    
    energyCosts = getTestEnergyCost(); % Loading Octopus Energy Data

    
% Send Data

    controllerData = struct('Temperature_Data', tempData, 'Solar_Data', solarData, 'Energy_Data', (energyCosts));
    testDataPack = jsonencode(controllerData);
end
%% Local Functions
function energyTestCosts = getTestEnergyCost()
    inputData = humanMachineInterface();
    inputData = jsondecode(inputData);
    beg = inputData.TestCase.begin_date;
    fin = inputData.TestCase.end_date;
    agileAPIImport = append('https://api.octopus.energy/v1/products/AGILE-18-02-21/electricity-tariffs/E-1R-AGILE-18-02-21-C/standard-unit-rates/?period_from=',string(beg),'&period_to=',string(fin));
    agileAPIExport = append('https://api.octopus.energy/v1/products/AGILE-OUTGOING-19-05-13/electricity-tariffs/E-1R-AGILE-OUTGOING-19-05-13-A/standard-unit-rates/?period_from=',string(beg),'&period_to=',string(fin));
    websave("agileAPIImport.json", agileAPIImport);
    energyImportData = readstruct("agileAPIImport.json");
    websave("agileAPIExport.json", agileAPIExport);
    energyExportData = readstruct("agileAPIExport.json");
    sizeS = size(energyImportData.results);
    s = sizeS(1,2);
    
    for i = 1:s
        energyImportCosts(i,1) = energyImportData.results(i).value_inc_vat;
        energyImportTimeBase(i,1) = energyImportData.results(i).valid_from;
        energyExportCosts(i,1) = energyExportData.results(i).value_inc_vat;
        energyExportTimeBase(i,1) = energyExportData.results(i).valid_from;
    end
    energyImportTimeBase = datetime(energyImportTimeBase, 'InputFormat','uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    energyImportCosts = struct('Energy_Import_Prices', flip(energyImportCosts), 'Energy_Import_Time_Base', flip(energyImportTimeBase));
    energyExportTimeBase = datetime(energyExportTimeBase, 'InputFormat','uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    energyExportCosts = struct('Energy_Export_Prices',flip(energyExportCosts),'Energy_Export_Time_Base',flip(energyExportTimeBase));
    energyTestCosts = struct('Energy_Import_Costs',energyImportCosts,'Energy_Export_Costs', energyExportCosts);
end

function solarTestData = getTestPVPower()
    inputData = humanMachineInterface();
    inputData = jsondecode(inputData);
    lat = inputData.location.lat;
    lon = inputData.location.lon;
    beg = datetime(inputData.TestCase.begin_date_short,"Format","uuuu-MM-dd",'TimeZone','UTC');
    fin = datetime(inputData.TestCase.end_date_short, "Format","uuuu-MM-dd",'TimeZone','UTC');
    solarIrradianceSite = append('https://archive-api.open-meteo.com/v1/archive?latitude=',string(lat),'&longitude=',string(lon),'&start_date=', string(beg), '&end_date=', string(fin), '&hourly=global_tilted_irradiance&tilt=40');
    websave("solarTestData.json", solarIrradianceSite);
    solarData = readstruct("solarTestData.json");

    avGTI = double(solarData.hourly.global_tilted_irradiance); % Average Global Tilted Irradiance
    solarTimeString = solarData.hourly.time;
    solarTime = datetime(solarTimeString, 'InputFormat','uuuu-MM-dd''T''HH:mm','TimeZone','UTC');

    xq = (solarTime(1):(1/48):solarTime(numel(solarTime)))';
    avGTI = interp1(solarTime, avGTI, xq);
    solarTime = xq;
        
    totalPVPowerWh = trapz(1:24, avGTI(1:24));
    totalPVPowerkWh = totalPVPowerWh/1000;
    
    solarTestData = struct('Total_PV_Power', totalPVPowerkWh, 'GTI', avGTI, 'Solar_Time_Base', solarTime);
end

function tempData = getTestWeather()
    inputData = humanMachineInterface();
    inputData = jsondecode(inputData);
    lat = inputData.location.lat;
    lon = inputData.location.lon;
    beg = datetime(inputData.TestCase.begin_date_short,"Format","uuuu-MM-dd",'TimeZone','UTC');
    fin = datetime(inputData.TestCase.end_date_short, "Format","uuuu-MM-dd",'TimeZone','UTC');
    openWeatherMapSite = append('https://archive-api.open-meteo.com/v1/archive?latitude=',string(lat),'&longitude=',string(lon),'&start_date=',string(beg),'&end_date=',string(fin),'&hourly=temperature_2m');
    websave("allData.json", openWeatherMapSite);
    allData = readstruct("allData.json");
    
    % Following loop allocates values of temperature and time to table
    averageTemps = zeros(numel(allData.hourly.time),1);
    
    for i = 1:numel(allData.hourly.time)
        averageTemps(i,1) = allData.hourly.temperature_2m(i);
        API_Time(i,1) = allData.hourly.time(i);
        converted_API_Time(i,1) = datetime(API_Time(i,1), "Format",'uuuu-MM-dd''T''HH:mm', 'TimeZone', 'UTC');
    end
    beg = datetime(inputData.TestCase.begin_date, 'InputFormat','yyyy-MM-dd''T''HH:mm:ss''Z', 'TimeZone', 'UTC');
    fin = datetime(inputData.TestCase.end_date, 'InputFormat','yyyy-MM-dd''T''HH:mm:ss''Z', 'TimeZone', 'UTC');
    xq = beg:1/48:fin;
    averageTemps = interp1(converted_API_Time, averageTemps, xq);
    API_Time = xq;
    tempData = struct('Average_Temperatures', averageTemps, 'Weather_Time_Base', API_Time);
    
end




