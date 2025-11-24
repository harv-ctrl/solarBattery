function [averageTemps, totalPVPowerkWh, energyCosts] = controller(lat, lon)
%% Loading Average Temperature Forecast
% API pulls data from OpenWeatherMap.org
    lat = 52.04;
    lon = -0.55;
    openWeatherMapSite = append('https://pro.openweathermap.org/data/2.5/forecast/hourly?lat=', string(lat), '&lon=', string(lon), '&appid=e7d8e5e8643aa76002fedf69a07e58ce&mode=xml&units=metric');
    websave("allData.xml", openWeatherMapSite);
    allData = readstruct("allData.xml");
    aveAttribute = size(48,1);
% Following loop allocates values of temperature and time to table
    for i = 1:48
        aveAttribute(i,1) = (allData.forecast.time(i).temperature.minAttribute + allData.forecast.time(i).temperature.maxAttribute)/2;
        API_Time(i,1) = allData.forecast.time(i).fromAttribute;
    end
    averageTemps = table(aveAttribute, API_Time);
    figure; plot(API_Time, aveAttribute);
    xlabel("Date and Time");
    ylabel("Average Temperature");
    title("Forecast Temperature for next 48 Hours");
%% Loading Solar Forecast
    solarIrradianceSite = append('https://seasonal-api.open-meteo.com/v1/seasonal?latitude=', string(lat), '&longitude=', string(lon), '&hourly=global_tilted_irradiance&models=ecmwf_seasonal_seamless&temporal_resolution=hourly_1&forecast_days=7&azimuth=0&tilt=40');
    websave("solarData.json", solarIrradianceSite);
    solarData = readstruct("solarData.json");

    avGTI = double(solarData.hourly.global_tilted_irradiance); % Average Global Tilted Irradiance
    solarTimeString = solarData.hourly.time;
    solarTime = datetime(solarTimeString, 'InputFormat','uuuu-MM-dd''T''HH:mm','TimeZone','UTC');
    
    totalPVPowerWh = trapz(1:24, avGTI(1:24));
    totalPVPowerkWh = totalPVPowerWh/1000;
    figure; plot(solarTime(1:24), avGTI(1:24).*18, 'r');
    xlabel("Date and Time");
    ylabel("Solar Power for 18m2 Setup (kW)");
    title("Forecast Global Tilted Irradiation for next 24 Hours");
%% Loading Octopus Energy Forecast
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
    figure; plot(energyTimeBase, energyCosts,'r');
    xlabel("Time");
    ylabel("Energy Cost (kWh)");
    title("Forecast Energy Usage");
end