function fval = optimisedCost()
    out = gatherOptimisationData();
    % Define all values to be used within the cost function
    global optimVars
    optimVars.ImportPrice = out.EC_Import_Price; 
    optimVars.ExportPrice = out.EC_Export_Price; 
    optimVars.Load  = out.HP_Power(:); Load = optimVars.Load;
    optimVars.PV    = out.PV_Power(:); PV = optimVars.PV;      
    optimVars.dt = 0.5; dt = optimVars.dt;                
    optimVars.N  = length(optimVars.ImportPrice); N = optimVars.N;
    optimVars.initCharge = 4; initCharge = optimVars.initCharge;              
    optimVars.maxCharge = 10; maxCharge = optimVars.maxCharge;
    
    lb = -2 * ones(N,1);  
    ub =  2 * ones(N,1);
    
    A = [];        
    b = [];
    
    A1 =  A;
    b1 =  b;
    
    A2 = -A;
    b2 = (maxCharge - initCharge) * ones(N,1);
    
    Aeq = ones(1,N);
    beq = zeros(1);
    
    x0 = zeros(N,1);
    
    options = optimoptions('fmincon','Display','iter','Algorithm','interior-point','MaxFunctionEvaluations',10e5);
    
    [x_opt, fval] = fmincon(@costFunction,x0,A,b,Aeq,beq,lb,ub,[],options);
    charge = initCharge - cumsum(x_opt);
    GridImport = (Load - PV - x_opt) * dt;
    disp(GridImport)
    
    figure;
    subplot(3,1,1)
    plot(out.PV_Time,charge,'LineWidth',1.5)
    ylabel('SOC (kWh)')
    grid on
    
    subplot(3,1,2)
    plot(out.PV_Time,x_opt,'LineWidth',1.5)
    ylabel('Battery Energy (kWh/step)')
    grid on
    
    subplot(3,1,3)
    plot(out.PV_Time,GridImport,'LineWidth',1.5)
    ylabel('Grid Import (kWh)')
    xlabel('Timestep')
    grid on
    
    figure
    plot(out.PV_Time,charge,'LineWidth',1.5)
    yline(0,'r--')
    yline(8,'r--')
    grid on
    ylabel('SOC (kWh)')
    xlabel('Time step')
    
    
    
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
    currentCharge(1) = initCharge;
    grid = Load-PV-x;
    f = sum((grid>0).*(grid).*ImportPrice + (grid<0).*(grid).*ExportPrice)*dt;
    penalty = 0;
    for i = 2:N+1
        currentCharge(i) = currentCharge(i-1) - x(i-1);
        if currentCharge(i) > 0.8*maxCharge
            penalty = penalty+(currentCharge(i)-0.8*maxCharge).^2;
        end
        if currentCharge(i) < 0.2*maxCharge
            penalty = penalty+(currentCharge(i)-0.2*maxCharge).^2;
            
        end
    end
    penaltyScale = 20;
    penalty = penalty*penaltyScale;
    
    f = f+penalty;
end
function out = gatherOptimisationData()
    dataPack = testController();
    data = jsondecode(dataPack);

    HP_Data = heatPump();
    HP_Data = jsondecode(HP_Data);
    
    PV_Data = solarPV();
    PV_Data = jsondecode(PV_Data);

    HP_Power = HP_Data.HP_Power;
    HP_Time = HP_Data.HP_Time_Base;
    HP_Time = datetime(HP_Time,"Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    
    PV_Time = PV_Data.PV_Time_Base;
    PV_Time = datetime(PV_Time,"Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    PV_Power = PV_Data.PV_Power./1000;

    EC_Import_Time = data.Energy_Data.Energy_Import_Costs.Energy_Import_Time_Base;
    EC_Import_Time = datetime(EC_Import_Time, "Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    EC_Import_Price = data.Energy_Data.Energy_Import_Costs.Energy_Import_Prices;
    
    EC_Export_Time = data.Energy_Data.Energy_Export_Costs.Energy_Export_Time_Base;
    EC_Export_Time = datetime(EC_Export_Time, "Format",'uuuu-MM-dd''T''HH:mm:ss''Z''', 'TimeZone', 'UTC');
    EC_Export_Price = data.Energy_Data.Energy_Export_Costs.Energy_Export_Prices;
    
    T_HP = timetable(HP_Time, HP_Power);
    T_PV = timetable(PV_Time, PV_Power);
    T_Import_EC = timetable(EC_Import_Time, EC_Import_Price);
    T_Export_EC = timetable(EC_Export_Time, EC_Export_Price);
    
    T1 = join(T_PV,T_HP);
    T2 = join(T_Import_EC,T_Export_EC);
    disp(T2)
    
    out = join(T1, T2);
       
    % figure;
    % plot(PV_Time(1:48),(HP_Power(1:48)-PV_Power(1:48)).*(EC_Price(1:48)),'g');
    
  end