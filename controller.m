function dataPack = controller()
% Receive Data

    inputVals = humanMachineInterface();
    inputVals = jsondecode(inputVals);

% Run APIs

    tempData = getWeather(); % Loading Average Temperature Forecast from OpenWeatherMap.org
    
    solarData = getPVPower(); % Loading Solar Forecast
    
    energyCosts = getEnergyCost(); % Loading Octopus Energy Data

% Build and Test Energy Profile

    
    
% Send Data

    controllerData = struct('Temperature_Data', tempData, 'Solar_Data', solarData, 'Energy_Data', energyCosts);
    dataPack = jsonencode(controllerData);
end
%% Local Functions
function energyCosts = getEnergyCost()
    beg = datetime("today", "Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    fin = datetime("tomorrow", "Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    agileAPI = append('https://api.octopus.energy/v1/products/AGILE-18-02-21/electricity-tariffs/E-1R-AGILE-18-02-21-C/standard-unit-rates/?period_from=',string(beg),'&period_to=',string(fin));
    websave("agileAPI.json", agileAPI);
    energyData = readstruct("agileAPI.json");
    sizeS = size(energyData.results);
    s = sizeS(1,2);
    for i = 1:s
        energyCosts(i,1) = energyData.results(i).value_inc_vat;
        energyTimeBaseString(i,1) = energyData.results(i).valid_from; 
    end
    energyTimeBase = datetime(energyTimeBaseString, 'InputFormat','uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    energyCosts = struct('Energy_Prices', energyCosts, 'Energy_Time_Base', energyTimeBase);
end

function solarData = getPVPower()
    inputVals = humanMachineInterface();
    inputVals = jsondecode(inputVals);
    lat = inputVals.location.lat;
    lon = inputVals.location.lon;
    solarIrradianceSite = append('https://seasonal-api.open-meteo.com/v1/seasonal?latitude=', string(lat), '&longitude=', string(lon), '&hourly=global_tilted_irradiance&models=ecmwf_seasonal_seamless&temporal_resolution=hourly_1&timezone=Europe%2FLondon&forecast_days=7&azimuth=0&tilt=40');
    websave("solarData.json", solarIrradianceSite);
    solarData = readstruct("solarData.json");

    avGTI = double(solarData.hourly.global_tilted_irradiance); % Average Global Tilted Irradiance
    solarTimeString = solarData.hourly.time;
    solarTime = datetime(solarTimeString, 'InputFormat','uuuu-MM-dd''T''HH:mm','TimeZone','UTC');

    totalPVPowerWh = trapz(1:24, avGTI(1:24));
    totalPVPowerkWh = totalPVPowerWh/1000;
    
    solarData = struct('Total_PV_Power', totalPVPowerkWh, 'GTI', avGTI, 'Solar_Time_Base', solarTime);
end

function tempData = getWeather()
    inputVals = humanMachineInterface();
    inputVals = jsondecode(inputVals);
    lat = inputVals.location.lat;
    lon = inputVals.location.lon;
    openWeatherMapSite = append('https://pro.openweathermap.org/data/2.5/forecast/hourly?lat=', string(lat), '&lon=', string(lon), '&appid=e7d8e5e8643aa76002fedf69a07e58ce&mode=xml&units=metric');
    websave("allData.xml", openWeatherMapSite);
    allData = readstruct("allData.xml");
    averageTemps = size(72,1);
   
    % Following loop allocates values of temperature and time to table
    for i = 1:72
        averageTemps(i,1) = (allData.forecast.time(i).temperature.minAttribute + allData.forecast.time(i).temperature.maxAttribute)/2;
        API_Time(i,1) = allData.forecast.time(i).fromAttribute;
    end
    tempData = struct('Average_Temperatures', averageTemps, 'Weather_Time_Base', API_Time);
end