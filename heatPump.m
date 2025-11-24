function [forecastData] = heatPump(setTemp)

dataPack = controller(); 
data = jsondecode(dataPack);

S = [];
setTemp = 19;
dataPack = controller(); 
data = jsondecode(dataPack);
heatLoss = 150;

S = data.Temperature_Data.Average_Temperatures;
T = struct2table(S);
T.API_Time = datetime(T.API_Time, 'InputFormat','uuuu-MM-dd''T''HH:mm:ss','TimeZone','UTC');

heatLossTotal = heatLoss.*(setTemp-T.aveAttribute);


figure; plot(T.API_Time(1:24), heatLossTotal(1:24));
xlabel('Time');
ylabel('Total Heat Loss');
title('Heat Loss');

end