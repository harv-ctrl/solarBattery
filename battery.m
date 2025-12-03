function batteryData = battery() % Limbo is sent from controller to specify battery action
% Read data sent fron Controller
   
    dataPack = controller();
    data = jsondecode(dataPack);
   
end

