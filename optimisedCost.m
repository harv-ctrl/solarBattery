function [DP,x_opt,plotData] = optimisedCost()
    out = gatherOptimisationData();
    % Define all values to be used within the cost function
    global optimVars
    optimVars.ImportPrice = out.EC_Import_Price(1:48); 
    optimVars.ExportPrice = out.EC_Export_Price(1:48); 
    optimVars.Load  = out.HP_Power(1:48); Load = optimVars.Load;
    optimVars.PV    = out.PV_Power(1:48); PV = optimVars.PV;      
    optimVars.dt = 0.5; dt = optimVars.dt;                
    optimVars.N  = length(optimVars.ImportPrice(1:48)); N = optimVars.N;
    optimVars.initCharge = 2; initCharge = optimVars.initCharge;              
    optimVars.maxCharge = 10; maxCharge = optimVars.maxCharge;
    optimVars.AP = out.AP_Power(1:48); AP = optimVars.AP;
    
    lb = -2 * ones(N,1);  
    ub =  2 * ones(N,1);
    
    A = []; A1 =  A; A2 = -A;        
    b = []; b1 =  b;  b2 = (maxCharge - initCharge) * ones(N,1);
    
    Aeq = ones(1,N);
    beq = zeros(1);
    x0 = 0*ones(N,1);
    
    options = optimoptions('fmincon','Display','iter','Algorithm','interior-point','MaxFunctionEvaluations',10e5);
    %options = optimoptions("fminimax","Display","iter","MaxIterations",10e5);
    [x_opt, ~] = fmincon(@costFunction,x0,A,b,Aeq,beq,lb,ub,[],options);
    %[x_opt, ~] = fminimax(@costFunction,x0,A,b,Aeq,beq,lb,ub,[],options);
    
    charge = initCharge - cumsum(x_opt);
    
    GridImport = (Load + AP - PV - x_opt) * dt;
    
    % figure;
    % subplot(3,1,1);
    % plot(out.PV_Time(1:48),charge,'LineWidth',1.5);
    % ylabel('SOC (kWh)');
    % grid on;
    % 
    % subplot(3,1,2);
    % plot(out.PV_Time(1:48),x_opt,'LineWidth',1.5);
    % ylabel('Battery Energy (kWh/step)');
    % grid on;
    % 
    % subplot(3,1,3);
    % plot(out.PV_Time(1:48),GridImport(1:48),'LineWidth',1.5);
    % ylabel('Grid Import (kWh)');
    % xlabel('Timestep');
    % grid on;
    % 
    % 
    % 
    % figure;
    % plot(out.PV_Time(1:48),charge,'LineWidth',1.5);
    % yline(1,'r--');
    % yline(9,'r--');
    % grid on;
    % ylabel('SOC (kWh)');
    % xlabel('Time step');
    
    IP = optimVars.ImportPrice;
    EP = optimVars.ExportPrice;
    plotData.unbalancedPower = Load+AP-PV;
    plotData.balancedPower = Load+AP-PV-x_opt;
    plotData.time = out.PV_Time(1:48);
    plotData.SOC = charge;
    plotData.batteryProfile = x_opt;

    plotData.PV = PV;
    
    
    UG = (Load+AP-PV);
    BG = Load+AP-PV-x_opt;
    
    plotData.DailyShiftedPrice = sum(((BG>0).*(BG).*IP + (BG<0).*(BG).*EP)*dt);
    plotData.unbalancedPrice = ((UG>0).*(UG).*IP + (UG<0).*(UG).*EP)*dt;
    plotData.balancedPrice = ((BG>0).*(BG).*IP + (BG<0).*(BG).*EP)*dt;
    plotData.DailyUnshiftedPrice = sum(((UG>0).*(UG).*IP + (UG<0).*(UG).*EP)*dt);
    DP = plotData.DailyUnshiftedPrice-plotData.DailyShiftedPrice;
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
    penalty = 0;
    for i = 2:N+1
        currentCharge(i) = currentCharge(i-1) - x(i-1);
        if currentCharge(i) > 0.9*maxCharge
            penalty = penalty+(currentCharge(i)-0.9*maxCharge).^2;
        end
        if currentCharge(i) < 0.1*maxCharge
            penalty = penalty+(currentCharge(i)-0.1*maxCharge).^2;
            
        end
    end
    penaltyScale = 20;
    penalty = penalty*penaltyScale;
    trial_penalty = 0.9*sum(diff(x).^2);
    f = f+penalty+trial_penalty;
    
    
end
function out = gatherOptimisationData()
    dataPack = testController();
    data = jsondecode(dataPack);

    HP_Data = heatPump();
    HP_Data = jsondecode(HP_Data);
    
    PV_Data = solarPV();
    PV_Data = jsondecode(PV_Data);

    AP_Data = homeAppliances();
    AP_Data = jsondecode(AP_Data);

    HP_Power = HP_Data.HP_Power;
    HP_Time = HP_Data.HP_Time_Base;
    HP_Time = datetime(HP_Time,"Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    
    PV_Time = PV_Data.PV_Time_Base;
    PV_Time = datetime(PV_Time,"Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    PV_Power = PV_Data.PV_Power./1000;

    AP_Time = AP_Data.AP_Time;
    AP_Time = datetime(AP_Time,"Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
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
end
