function PV_Data = solarPV()
%% Today
    dataPack = testController();
    data = jsondecode(dataPack);
    inputData = humanMachineInterface();
    inputData = jsondecode(inputData);
    GTI = data.Solar_Data.GTI;
    PVTimeBase = data.Solar_Data.Solar_Time_Base;
    
    numPanels = inputData.PVData.numPanels;
    panelArea = inputData.PVData.panelArea;
    PV_Power = GTI.*(numPanels).*(panelArea);
    
    PV_Data.PV_Power = PV_Power;
    for i = 1:numel(PVTimeBase)
        PV_Data.PV_Time_Base(i,1) = PVTimeBase(i);
    end
    PV_Data = jsonencode(PV_Data);
end
