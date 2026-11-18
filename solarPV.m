function PV_Data = solarPV(data, inputData) %nargin = "if no data supplied, download it"
    if nargin < 2
    inputData = humanMachineInterface();
    end

    if nargin < 1
    data = testController();
    end

    % Reads amount of power incident
    GTI = data.Solar_Data.GTI;
    PVTimeBase = data.Solar_Data.Solar_Time_Base;
    numPanels = inputData.PVData.numPanels;
    panelArea = inputData.PVData.panelArea;
    
    % Applies panel efficiency
    efficiency = 0.2;
    pvPower = GTI.*(numPanels).*(panelArea).*efficiency; 
    pvEnergy = sum(pvPower)*0.5;
    PV_Data = struct('PV_Power',pvPower,'PV_Energy',pvEnergy/1000,'PV_Time_Base',PVTimeBase);
end
