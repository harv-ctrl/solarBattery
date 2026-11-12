function [DP,UP,SP,x_opt,plotData] = optimisedCost()
    % Runs local function to collect data from components
    out = gatherOptimisationData();

    % Define all values to be used within the cost function
    global optimVars

    %% Specify Battery Information --------------------------- INPUT HERE
    optimVars.initCharge = 2; % This is the initial daily charge of the battery, set initially as 2 kWh
    optimVars.maxCharge = 10; % This is the maximum capacity as written in the humanMachineInterface

    %%
    optimVars.ImportPrice = out.EC_Import_Price(1:48); 
    optimVars.ExportPrice = out.EC_Export_Price(1:48); 
    optimVars.Load  = out.HP_Power(1:48); Load = optimVars.Load;
    optimVars.PV    = out.PV_Power(1:48); PV = optimVars.PV;      
    optimVars.dt = 0.5; dt = optimVars.dt;                
    optimVars.N  = length(optimVars.ImportPrice(1:48)); N = optimVars.N;
    initCharge = optimVars.initCharge;              
    optimVars.AP = out.AP_Power(1:48); AP = optimVars.AP;
    
    % Optimisation restraints
    lb = -2 * ones(N,1);  
    ub =  2 * ones(N,1);
    %A = [];       
    %b = [];
    %Below alteration would set proper restraints for 10% tolerance on that
    %battery (H)
    cumulativePower = tril(ones(N));
     A = [-dt*cumulativePower; dt*cumulativePower];

     b = [(0.9*optimVars.maxCharge - initCharge)*ones(N,1); (initCharge - 0.1*optimVars.maxCharge)*ones(N,1)];
    
    Aeq = ones(1,N);
    beq = zeros(1);

    % Initial guess (battery unused)
    x0 = 0*ones(N,1);
    
    options = optimoptions('fmincon','Algorithm','interior-point','MaxFunctionEvaluations',10e5,'Display','off');
    [x_opt, ~] = fmincon(@costFunction,x0,A,b,Aeq,beq,lb,ub,[],options);
    
    % Gather data for internal cost logic
    IP = optimVars.ImportPrice;
    EP = optimVars.ExportPrice;
    UG = (Load+AP-PV); 
    BG = Load+AP-PV-x_opt; 
    
    % Generate data for app plotting
    plotData.unbalancedPower = Load+AP-PV; 
    plotData.balancedPower = Load+AP-PV-x_opt; 
    plotData.time = out.PV_Time(1:48);
    plotData.SOC = initCharge - cumsum(x_opt)*dt; %added *dt here as well (H)
    plotData.batteryProfile = x_opt;
    plotData.PV = PV;
    plotData.DailyShiftedPrice = sum(((BG>0).*(BG).*IP + (BG<0).*(BG).*EP)*dt);
    plotData.unbalancedPrice = ((UG>0).*(UG).*IP + (UG<0).*(UG).*EP)*dt;
    plotData.balancedPrice = ((BG>0).*(BG).*IP + (BG<0).*(BG).*EP)*dt;
    plotData.DailyUnshiftedPrice = sum(((UG>0).*(UG).*IP + (UG<0).*(UG).*EP)*dt);
    
    % Exports data for findBestDay()
    DP = plotData.DailyUnshiftedPrice-plotData.DailyShiftedPrice;
    UP = plotData.DailyUnshiftedPrice;
    SP = plotData.DailyShiftedPrice;
end

function f = costFunction(x)
    global optimVars
    initCharge = optimVars.initCharge;
    maxCharge = optimVars.maxCharge;
    ImportPrice = optimVars.ImportPrice;
    ExportPrice = optimVars.ExportPrice;
    Load = optimVars.Load;
    PV = optimVars.PV;
    dt = optimVars.dt;
    N = optimVars.N;
    AP = optimVars.AP;
    currentCharge(1) = initCharge;
    grid = Load+AP-PV-x; 
    f = sum((grid>0).*(grid).*ImportPrice + (grid<0).*(grid).*ExportPrice)*dt;
  
    % Calculate penalty for cost function
    penalty = 0;
    for i = 2:N+1
        currentCharge(i) = currentCharge(i-1) - x(i-1)*dt; %Added the dt here. Shouldn't it multiply by the half hour?? (H)
        if currentCharge(i) > 0.9*maxCharge
            penalty = penalty+(currentCharge(i)-0.9*maxCharge).^2;
        end
        if currentCharge(i) < 0.1*maxCharge
            penalty = penalty+(currentCharge(i)-0.1*maxCharge).^2;
        end
    end
    
    % Penalty togglables, hand-tuned
    penaltyScale = 20;
    penalty = penalty*penaltyScale;
    trial_penalty = 0.9*sum(diff(x).^2);
    f = f+penalty+trial_penalty;
end
function out = gatherOptimisationData()
    % Check all components are working properly
    data = testController();
    HP_Data = heatPump();
    PV_Data = solarPV();
    AP_Data = homeAppliances();
    HP_Power = HP_Data.HP_Power;
    HP_Time = HP_Data.HP_Time_Base;
    PV_Time = PV_Data.PV_Time_Base;
    PV_Power = PV_Data.PV_Power./1000;
    AP_Time = AP_Data.AP_Time;
    AP_Power = AP_Data.AP_Power;
    EC_Import_Time = data.Energy_Data.Energy_Import_Costs.Energy_Import_Time_Base;
    EC_Import_Time = datetime(EC_Import_Time, "Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    EC_Import_Price = data.Energy_Data.Energy_Import_Costs.Energy_Import_Prices;
    EC_Export_Time = data.Energy_Data.Energy_Export_Costs.Energy_Export_Time_Base;
    EC_Export_Time = datetime(EC_Export_Time, "Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    EC_Export_Price = data.Energy_Data.Energy_Export_Costs.Energy_Export_Prices;
    T_HP = timetable(HP_Time, HP_Power);
    T_PV = timetable(PV_Time, PV_Power);
    T_AP = timetable(AP_Time, AP_Power);
    T_Import_EC = timetable(EC_Import_Time, EC_Import_Price);
    T_Export_EC = timetable(EC_Export_Time, EC_Export_Price);
    T1 = join(T_PV,T_HP);
    T2 = join(T_Import_EC,T_Export_EC);
    T3 = join(T1,T2);
    out = join(T3,T_AP);
    % This generates a timetable of all component values.
end

