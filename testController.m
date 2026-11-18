function data = testController()
disp('Downloading weather and tariff data');
    % Gather initial values for API queries
    inputData = humanMachineInterface();

    %% SECTION HERE TO REDUCE NUMBER OF OPEN-METEO CALLS (I'm running out)
    global allData 
    lat = inputData.location.lat;
    lon = inputData.location.lon;
    beg = datetime(inputData.TestCase.begin_date_short,"Format","uuuu-MM-dd",'TimeZone','UTC');
    fin = datetime(inputData.TestCase.end_date_short, "Format","uuuu-MM-dd",'TimeZone','UTC');
    weatherSite = append('https://archive-api.open-meteo.com/v1/archive?latitude=',string(lat),'&longitude=',string(lon),'&start_date=',string(beg),'&end_date=',string(fin),'&hourly=temperature_2m&hourly=global_tilted_irradiance&tilt=40');
    allData = [];
    try
        allData = webread(weatherSite);
    catch ME
        error('testController:WeatherDownloadFailed', 'Open-Meteo download failed for %s to %s. Details: %s', char(beg), char(fin), ME.message);
    end
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
    agileAPIImport = append('https://api.octopus.energy/v1/products/AGILE-18-02-21/electricity-tariffs/E-1R-AGILE-18-02-21-B/standard-unit-rates/?period_from=',string(beg),'&period_to=',string(fin));
    agileAPIExport = append('https://api.octopus.energy/v1/products/AGILE-OUTGOING-19-05-13/electricity-tariffs/E-1R-AGILE-OUTGOING-19-05-13-B/standard-unit-rates/?period_from=',string(beg),'&period_to=',string(fin));
   % The Codes in the URLs are important, as the ending letter determines
   % their group. Coventry is B, so changed both to B
    energyImportData = webread(agileAPIImport);
    energyExportData = webread(agileAPIExport);

    % Read import prices and their timestamps
    importCount = numel(energyImportData.results); %counts how many records were downloaded
    importPrices = zeros(importCount,1); 
    importTimes = strings(importCount,1);

    for i = 1:importCount
        importPrices(i) = energyImportData.results(i).value_inc_vat; % price including VAT
        importTimes(i) = energyImportData.results(i).valid_from; % supplies the time price begins
    end

    % Read export prices and their timestamps (Exports now retain their own
    % timestamps to match up better
    exportCount = numel(energyExportData.results); 
    exportPrices = zeros(exportCount,1);
    exportTimes = strings(exportCount,1);

    for i = 1:exportCount
        exportPrices(i) = energyExportData.results(i).value_inc_vat;
        exportTimes(i) = energyExportData.results(i).valid_from;
    end

    % Convert timestamp text into MATLAB dates
    timeFormat = "uuuu-MM-dd'T'HH:mm:ss'Z'";

    importTimes = datetime(importTimes, ...
        'InputFormat', timeFormat, 'TimeZone', 'UTC');

    exportTimes = datetime(exportTimes, ...
        'InputFormat', timeFormat, 'TimeZone', 'UTC');

    % Select the exact 48 half-hours required for the test day
    dayStart = datetime(beg, ...
        'InputFormat', timeFormat, 'TimeZone', 'UTC');

    expectedTimes = dayStart + minutes((0:30:1410)'); %makes the 48 timestamps as a column of half hour intervals

    [importFound, importIndex] = ismember(expectedTimes, importTimes);
    [exportFound, exportIndex] = ismember(expectedTimes, exportTimes);

    assert(all(importFound), 'Import prices are missing for the test day.');
    assert(all(exportFound), 'Export prices are missing for the test day.');

    % Return prices matched to the correct half-hours
    importCosts = struct( ... %struct puts prices & times into named fields for the code to function
        'Energy_Import_Prices', importPrices(importIndex), ... % this bit orders prices to match required timestamps
        'Energy_Import_Time_Base', expectedTimes);

    exportCosts = struct( ...
        'Energy_Export_Prices', exportPrices(exportIndex), ...
        'Energy_Export_Time_Base', expectedTimes);

    energyCosts = struct( ...
        'Energy_Import_Costs', importCosts, ...
        'Energy_Export_Costs', exportCosts);
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
    
    solarTestData = struct('GTI', avGTI(1:48), 'Solar_Time_Base', solarTime(1:48));
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
    tempData = struct('Average_Temperatures', averageTemps(1:48)', 'Weather_Time_Base', API_Time(1:48)');
end




