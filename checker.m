%% 1. Select the single-day settings from humanMachineInterface
global bestDay
bestDay = false;

inputData = humanMachineInterface();
data = testController();

HP = heatPump(data, inputData);
PV = solarPV(data, inputData);
AP = homeAppliances(data, inputData);

dt = 0.5; % hours

%% 2. Check the location and requested day
fprintf('\n--- LOCATION AND DATE ---\n');
fprintf('Latitude: %.4f\n', inputData.location.lat);
fprintf('Longitude: %.4f\n', inputData.location.lon);
fprintf('Requested day: %s\n', ...
    char(inputData.TestCase.begin_date_short));

%% 3. Collect all timestamps and power values
times = {HP.HP_Time_Base(:), PV.PV_Time_Base(:), AP.AP_Time(:), ...
    data.Energy_Data.Energy_Import_Costs.Energy_Import_Time_Base(:), ...
    data.Energy_Data.Energy_Export_Costs.Energy_Export_Time_Base(:)};

importPrice = ...
    data.Energy_Data.Energy_Import_Costs.Energy_Import_Prices(:);
exportPrice = ...
    data.Energy_Data.Energy_Export_Costs.Energy_Export_Prices(:);

% Convert PV power from W to kW.
power = [HP.HP_Power(:), PV.PV_Power(:)/1000, AP.AP_Power(:)];

dayStart = datetime(inputData.TestCase.begin_date_short, ...
    'InputFormat', 'yyyy-MM-dd', 'TimeZone', 'UTC');
expectedTimes = dayStart + minutes((0:30:1410)');

%% 4. Check the length, spacing and alignment of every time series
for k = 1:numel(times)
    assert(numel(times{k}) == 48, ...
        'A time series does not contain exactly 48 timestamps.');
    assert(all(times{k} == expectedTimes), ...
        'A time series does not match the required UTC half-hours.');
end

assert(isequal(size(power), [48 3]), ...
    'Component power profiles must each contain 48 values.');
assert(all(isfinite(power(:))), ...
    'Component power contains missing or invalid values.');
assert(all(power(:) >= 0), ...
    'A component has negative demand or generation.');

assert(numel(importPrice) == 48 && numel(exportPrice) == 48, ...
    'A tariff profile does not contain 48 prices.');
assert(all(isfinite([importPrice; exportPrice])), ...
    'Tariff prices contain missing or invalid values.');

fprintf('\nPASS: All five time bases match the required 48 half-hours.\n');
fprintf('PASS: Component power and tariff values are valid.\n');

%% 5. Independently total the component energy from power
componentEnergy = sum(power, 1)*dt;
reportedEnergy = [HP.HP_Energy, PV.PV_Energy, AP.AP_Energy];

assert(all(abs(componentEnergy - reportedEnergy) < 1e-8), ...
    'A reported component energy does not match its power profile.');

assert(abs(AP.AP_Energy - inputData.ApplianceData.totalEnergy) < 1e-8, ...
    'Appliance energy does not match the configured daily total.');

fprintf('PASS: Component energy totals match their power profiles.\n');
fprintf('PASS: Appliance energy matches the configured total.\n');

%% 6. Calculate household energy and the bill with the battery idle
householdPower = power(:,1) + power(:,3);
netGridPower = householdPower - power(:,2);

importEnergy = sum(max(netGridPower, 0))*dt;
exportEnergy = sum(max(-netGridPower, 0))*dt;
householdEnergy = sum(householdPower)*dt;
pvEnergy = componentEnergy(2);

balanceError = householdEnergy + exportEnergy ...
    - pvEnergy - importEnergy;

assert(abs(balanceError) < 1e-8, ...
    'The household energy balance does not close.');

idleBillPence = sum( ...
    max(netGridPower, 0).*importPrice ...
    - max(-netGridPower, 0).*exportPrice)*dt;

fprintf('\n--- HOUSEHOLD RESULTS: BATTERY IDLE ---\n');
fprintf('Heat pump, including hot water: %.4f kWh\n', componentEnergy(1));
fprintf('Washing and dishwasher:         %.4f kWh\n', componentEnergy(3));
fprintf('Total modelled consumption:     %.4f kWh\n', householdEnergy);
fprintf('PV generation:                  %.4f kWh\n', pvEnergy);
fprintf('Grid imports:                   %.4f kWh\n', importEnergy);
fprintf('Grid exports:                   %.4f kWh\n', exportEnergy);
fprintf('Energy balance error:           %.10f kWh\n', balanceError);
fprintf('Electricity bill:               £%.4f\n', idleBillPence/100);