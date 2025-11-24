function [forecastData] = heatPump()

% API pulls data from OpenWeatherMap.org
tempsURL = 'https://api.openweathermap.org/data/2.5/forecast?lat=51.5&lon=-0.14&appid=e7d8e5e8643aa76002fedf69a07e58ce&mode=xml';
websave("temps.xml", tempsURL);
S = readstruct("temps.xml");
forecastData = S.forecast.time.temperature;
disp(forecastData)


end
