function checker(testDay)
%% 1. Select the requested test day
if nargin < 1
    testDay = '2026-01-01';
end

global bestDay date

% Restore the previous date settings when this function finishes,
% including if a check fails.
previousBestDay = bestDay;
previousDate = date;
cleanup = onCleanup(@() restoreDateSettings( ...
    previousBestDay, previousDate));

selectedDay = datetime(testDay, ...
    'InputFormat', 'yyyy-MM-dd', 'TimeZone', 'UTC');
followingDay = selectedDay + caldays(1);

date = struct();
date.start = string(selectedDay, "yyyy-MM-dd'T'HH:mm:ss'Z'");
date.end = string(followingDay + hours(23) + minutes(30), ...
    "yyyy-MM-dd'T'HH:mm:ss'Z'");
date.ss = string(selectedDay, 'yyyy-MM-dd');
date.se = string(followingDay, 'yyyy-MM-dd');

bestDay = true;

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
fprintf('Requested day: %s\n', char(inputData.TestCase.begin_date_short));

%% 3. Collect all timestamps and power values
times = {HP.HP_Time_Base(:), PV.PV_Time_Base(:), AP.AP_Time(:), ...
    data.Energy_Data.Energy_Import_Costs.Energy_Import_Time_Base(:), ...
    data.Energy_Data.Energy_Export_Costs.Energy_Export_Time_Base(:)};

importPrice = data.Energy_Data.Energy_Import_Costs.Energy_Import_Prices(:);
exportPrice = data.Energy_Data.Energy_Export_Costs.Energy_Export_Prices(:);

% Convert PV power from W to kW.
power = [HP.HP_Power(:), PV.PV_Power(:)/1000, AP.AP_Power(:)];

dayStart = datetime(inputData.TestCase.begin_date_short, 'InputFormat', 'yyyy-MM-dd', 'TimeZone', 'UTC');
expectedTimes = dayStart + minutes((0:30:1410)');

%% 4. Check the length, spacing and alignment of every time series
for k = 1:numel(times)
    assert(numel(times{k}) == 48, 'A time series does not contain exactly 48 timestamps.');
    assert(all(times{k} == expectedTimes), 'A time series does not match the required UTC half-hours.');
end

assert(isequal(size(power), [48 3]),'Component power profiles must each contain 48 values.');
assert(all(isfinite(power(:))), 'Component power contains missing or invalid values.');
assert(all(power(:) >= 0), 'A component has negative demand or generation.');

assert(numel(importPrice) == 48 && numel(exportPrice) == 48, 'A tariff profile does not contain 48 prices.');
assert(all(isfinite([importPrice; exportPrice])), 'Tariff prices contain missing or invalid values.');

fprintf('\nPASS: All five time bases match the required 48 half-hours.\n');
fprintf('PASS: Component power and tariff values are valid.\n');

%% 5. Independently total the component energy from power
componentEnergy = sum(power, 1)*dt;
reportedEnergy = [HP.HP_Energy, PV.PV_Energy, AP.AP_Energy];

assert(all(abs(componentEnergy - reportedEnergy) < 1e-8), 'A reported component energy does not match its power profile.');

expectedApplianceEnergy = inputData.ApplianceData.totalEnergy ...
    + inputData.ApplianceData.fridgeFreezerEnergy ...
    + inputData.ApplianceData.lightingEnergy ...
    + inputData.ApplianceData.cookingEnergy ...
    + inputData.ApplianceData.electronicsEnergy ...
    + inputData.ApplianceData.otherEnergy;

assert(abs(AP.AP_Energy - expectedApplianceEnergy) < 1e-8, 'Appliance energy does not match the configured daily total.');

fprintf('PASS: Component energy totals match their power profiles.\n');
fprintf('PASS: Appliance energy matches the configured total.\n');

%% 6. Calculate household energy and the bill with the battery idle
householdPower = power(:,1) + power(:,3);
netGridPower = householdPower - power(:,2);

importEnergy = sum(max(netGridPower, 0))*dt;
exportEnergy = sum(max(-netGridPower, 0))*dt;
householdEnergy = sum(householdPower)*dt;
pvEnergy = componentEnergy(2);

balanceError = householdEnergy + exportEnergy - pvEnergy - importEnergy;

assert(abs(balanceError) < 1e-8, 'The household energy balance does not close.');

idleBillPence = sum(max(netGridPower, 0).*importPrice - max(-netGridPower, 0).*exportPrice)*dt;

fprintf('\n--- HOUSEHOLD RESULTS: BATTERY IDLE ---\n');
fprintf('Heat pump, including hot water: %.4f kWh\n', componentEnergy(1));
fprintf('Appliance demand:               %.4f kWh\n', componentEnergy(3));
fprintf('Total modelled consumption:     %.4f kWh\n', householdEnergy);
fprintf('PV generation:                  %.4f kWh\n', pvEnergy);
fprintf('Grid imports:                   %.4f kWh\n', importEnergy);
fprintf('Grid exports:                   %.4f kWh\n', exportEnergy);
fprintf('Energy balance error:           %.10f kWh\n', balanceError);
fprintf('Electricity bill:               £%.4f\n', idleBillPence/100);

%% 7. Run the optimiser and compare its household inputs
[DP, UP, SP, x_opt, plotData] = optimisedCost();

tol = 1e-6;
x = x_opt(:);

assert(numel(x) == 48 && all(isfinite(x)), ...
    'Battery schedule must contain 48 finite values.');

assert(isequal(plotData.time(:), expectedTimes), ...
    'Optimiser timestamps differ from the household check.');

assert(max(abs(plotData.unbalancedPower(:) - netGridPower)) < tol, ...
    'Optimiser household inputs differ from the household check.');

%% 8. Independently reconstruct battery energy and grid power
% These values match the current settings in optimisedCost.m.
initialEnergy = 2; % kWh
minimumEnergy = 1; % kWh
maximumEnergy = 9; % kWh
powerLimit = 2;    % kW

chargeEfficiency = inputData.battery.chargeEfficiency;
dischargeEfficiency = inputData.battery.dischargeEfficiency;

chargingPower = max(-x, 0);
dischargingPower = max(x, 0);

storedEnergy = initialEnergy + cumsum( ...
    chargingPower*chargeEfficiency ...
    - dischargingPower/dischargeEfficiency)*dt;
scheduledGrid = netGridPower - x;

assert(all(abs(x) <= powerLimit + tol), ...
    'Battery power limit exceeded.');

assert(all(storedEnergy >= minimumEnergy - tol) && ...
    all(storedEnergy <= maximumEnergy + tol), ...
    'Battery stored-energy limit exceeded.');

assert(abs(storedEnergy(end) - initialEnergy) < tol, ...
    'Battery does not finish at its starting energy.');

assert(max(abs(storedEnergy - plotData.SOC(:))) < tol, ...
    'Reported battery energy differs from the independent calculation.');

assert(max(abs(scheduledGrid - plotData.balancedPower(:))) < tol, ...
    'Reported grid power differs from the independent calculation.');

%% 9. Independently check the scheduled bill and savings
scheduledBillPence = sum( ...
    max(scheduledGrid, 0).*importPrice ...
    - max(-scheduledGrid, 0).*exportPrice)*dt;

assert(abs(UP - idleBillPence) < tol, ...
    'Reported idle bill differs from the independent calculation.');

assert(abs(SP - scheduledBillPence) < tol, ...
    'Reported scheduled bill differs from the independent calculation.');

assert(abs(DP - (idleBillPence - scheduledBillPence)) < tol, ...
    'Reported saving differs from the independent calculation.');

%% 10. Check the whole-day energy balance with the battery losses
scheduledImports = sum(max(scheduledGrid, 0))*dt;
scheduledExports = sum(max(-scheduledGrid, 0))*dt;
chargingEnergy = sum(chargingPower)*dt;
dischargingEnergy = sum(dischargingPower)*dt;

chargingLoss = chargingEnergy*(1 - chargeEfficiency);
dischargingLoss = dischargingEnergy*(1/dischargeEfficiency - 1);
totalBatteryLoss = chargingLoss + dischargingLoss;

batteryEnergyChange = storedEnergy(end) - initialEnergy;

% Electricity entering must account for output, losses
% and any change in stored energy.
batteryBalanceError = chargingEnergy - dischargingEnergy ...
    - totalBatteryLoss - batteryEnergyChange;

assert(abs(batteryBalanceError) < tol, ...
    'Battery energy balance does not close.');

% Household supply must account for demand, exports,
% battery losses and any change in stored energy.
scheduledBalanceError = pvEnergy + scheduledImports ...
    - householdEnergy - scheduledExports ...
    - totalBatteryLoss - batteryEnergyChange;

assert(abs(scheduledBalanceError) < tol, ...
    'Scheduled household energy balance does not close.');

fprintf('\n--- BATTERY LOSSES ---\n');
fprintf('Electricity entering battery: %.6f kWh\n', chargingEnergy);
fprintf('Electricity leaving battery:  %.6f kWh\n', dischargingEnergy);
fprintf('Charging losses:              %.6f kWh\n', chargingLoss);
fprintf('Discharging losses:           %.6f kWh\n', dischargingLoss);
fprintf('Total battery losses:         %.6f kWh\n', totalBatteryLoss);
fprintf('Battery balance error:        %.10f kWh\n', batteryBalanceError);
fprintf('Household balance error:      %.10f kWh\n', scheduledBalanceError);

fprintf('PASS: Battery losses and energy balances agree.\n');

fprintf('\nPASS: Optimiser inputs match the household check.\n');
fprintf('PASS: Battery power, energy and final-charge constraints hold.\n');
fprintf('PASS: Reported battery and grid profiles match calculations.\n');
fprintf('PASS: Bills and savings match independent calculations.\n');
fprintf('PASS: Scheduled household energy balance closes.\n');

fprintf('\n--- OPTIMISED BATTERY RESULTS ---\n');
fprintf('Grid imports:          %.4f kWh\n', scheduledImports);
fprintf('Grid exports:          %.4f kWh\n', scheduledExports);
fprintf('Idle-battery bill:     £%.4f\n', UP/100);
fprintf('Scheduled bill:        £%.4f\n', SP/100);
fprintf('Saving:                £%.4f\n', DP/100);
%% 11. Separate space heating and hot-water demand
% Hot water disabled
spaceOnlySettings = inputData; % settings with the hot water switched OFF
spaceOnlySettings.heatPump.hotWaterEnergy = 0;

spaceOnly = heatPump(data, spaceOnlySettings); % heat pump results for hotWater OFF

spacePower = spaceOnly.HP_Power(:); % Electricity demand for space heating
hotWaterPower = HP.HP_Power(:) - spacePower; %heat pump demand - space heating demand

spaceEnergy = sum(spacePower)*dt;
hotWaterEnergy = sum(hotWaterPower)*dt;

%% 12. Check the hot-water requirement
% Current assumption:   90 litres heated through 40 degrees C.
expectedThermalEnergy = 90     *4.18*            40 /   3600; % Energy in hot water
expectedElectricalEnergy = expectedThermalEnergy/inputData.heatPump.COP;% Heat/COP

hotWaterStart = datetime( ...
    append(inputData.TestCase.begin_date_short, ...
    inputData.heatPump.HW_Start), ...
    'InputFormat', "yyyy-MM-dd'T'HH:mm:ss'Z'", ...
    'TimeZone', 'UTC'); % 11:00, attached to the test date

hotWaterEnd = datetime( ...
    append(inputData.TestCase.begin_date_short, ...
    inputData.heatPump.HW_End), ...
    'InputFormat', "yyyy-MM-dd'T'HH:mm:ss'Z'", ...
    'TimeZone', 'UTC'); % 15:00 attached to test date

hotWaterWindow = expectedTimes >= hotWaterStart & expectedTimes < hotWaterEnd;

windowHours = hours(hotWaterEnd - hotWaterStart); % Length of window (4h)
expectedHotWaterPower = expectedElectricalEnergy/windowHours; % Expected electricity use divided by the window length

assert(abs(hotWaterEnergy - expectedElectricalEnergy) < tol, ...
    'Hot-water electrical energy does not match the requirement.');

assert(all(abs(hotWaterPower(~hotWaterWindow)) < tol), ...
    'Hot-water demand appears outside the configured window.');

assert(all(abs(hotWaterPower(hotWaterWindow) ...
    - expectedHotWaterPower) < tol), ...
    'Hot-water power does not match the configured window length.');

%% 13. Check space-heating limits and warm-weather cutoff
outdoorTemp = data.Temperature_Data.Average_Temperatures(:);

assert(all(spacePower >= -tol & spacePower <= 5 + tol), ...
    'Space-heating electrical power is outside 0–5 kW.');

assert(all(abs(spacePower(outdoorTemp > 17)) < tol), ...
    'Space heating operates above the current 17 C cutoff.');

assert(abs(spaceEnergy + hotWaterEnergy - HP.HP_Energy) < tol, ...
    'Space-heating and hot-water energy do not sum to the HP total.');

fprintf('\n--- HEATING AND HOT WATER ---\n');
fprintf('Outdoor temperature range:       %.2f to %.2f C\n', ...
    min(outdoorTemp), max(outdoorTemp));
fprintf('Space-heating electricity:        %.4f kWh\n', spaceEnergy);
fprintf('Hot-water heat requirement:       %.4f kWh thermal\n', ...
    expectedThermalEnergy);
fprintf('Expected hot-water electricity:   %.4f kWh\n', ...
    expectedElectricalEnergy);
fprintf('Modelled hot-water electricity:   %.4f kWh\n', ...
    hotWaterEnergy);
fprintf('Hot-water window:                 %.2f hours\n', windowHours);
fprintf('Hot-water electrical power:       %.4f kW\n', ...
    expectedHotWaterPower);
fprintf('Maximum space-heating power:      %.4f kW\n', max(spacePower));

fprintf('\nPASS: Hot-water energy, timing and power agree.\n');
fprintf('PASS: Space-heating limits and temperature cutoff hold.\n');
fprintf('PASS: Space heating plus hot water matches the HP total.\n');
fprintf('Final battery energy on %s: %.6f kWh\n', ...
    char(date.ss), plotData.SOC(end));
fprintf('\nALL CHECKS PASSED FOR %s\n', char(date.ss));
end

function restoreDateSettings(previousBestDay, previousDate)
global bestDay date
bestDay = previousBestDay;
date = previousDate;
end