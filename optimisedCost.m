function fval = optimisedCost()
    out = energyOptimiser();
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