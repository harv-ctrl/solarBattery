function [YearData,YearShiftData,EA_Data] = findBestDay()
    global date
        for k = 1:12
        dayNum = [31,28,31,30,31,30,31,31,30,31,30,31];
            for i = 1:dayNum(k)
                
                if i < dayNum(k) 
                    
                    date.start = append('2025-',pad(string(k),2,'left','0'),'-',pad(string(i),2,'left','0'),'T00:00:00Z');
                    date.end = append('2025-',pad(string(k),2,'left','0'),'-',pad(string(i+1),2,'left','0'),'T23:30:00Z');
                    date.ss = append('2025-',pad(string(k),2,'left','0'),'-',pad(string(i),2,'left','0'));
                    date.se = append('2025-',pad(string(k),2,'left','0'),'-',pad(string(i+1),2,'left','0'));
                    [DP,UP,SP,~,~] = optimisedCost();
                    unshift_value(i,k) = UP;
                    shift_value(i,k) = SP;
                    value(i,k) = DP;
                    time(i,k) = date.start;
                    GasEnergy(i,k) = calculateGasCost();
                    
                    
                    
                else
                    if k < 12
                        
                        date.start = append('2025-',pad(string(k),2,'left','0'),'-',pad(string(i),2,'left','0'),'T00:00:00Z');
                        date.end = append('2025-',pad(string(k+1),2,'left','0'),'-',pad(string(1),2,'left','0'),'T23:30:00Z');
                        date.ss = append('2025-',pad(string(k),2,'left','0'),'-',pad(string(i),2,'left','0'));
                        date.se = append('2025-',pad(string(k+1),2,'left','0'),'-',pad(string(1),2,'left','0'));
                        [DP,UP,SP,~,~] = optimisedCost();
                        unshift_value(i,k) = UP;
                        shift_value(i,k) = SP;
                        value(i,k) = DP;
                        time(i,k) = date.start;
                        GasEnergy(i,k) = calculateGasCost();
                        
                        
                        
                    else
                        
                        date.start = append('2025-',pad(string(12),2,'left','0'),'-',pad(string(31),2,'left','0'),'T00:00:00Z');
                        date.end = append('2026-',pad(string(1),2,'left','0'),'-',pad(string(1),2,'left','0'),'T23:30:00Z');
                        date.ss = append('2025-',pad(string(12),2,'left','0'),'-',pad(string(31),2,'left','0'));
                        date.se = append('2026-',pad(string(1),2,'left','0'),'-',pad(string(1),2,'left','0'));
                        [DP,UP,SP,~,~] = optimisedCost();
                        unshift_value(i,k) = UP;
                        shift_value(i,k) = SP;
                        value(i,k) = DP;
                        time(i,k) = date.start;
                        GasEnergy(i,k) = calculateGasCost();                                    
                    end
                end
                
                
                disp(date.start);
                
                
            end 
            
        end
        YearData = struct('Value',value,'Time',time);
        YearShiftData = struct('Shifted_Value',shift_value,'Unshifted_Value',unshift_value,'Time',time);
        EA_Data = struct('Daily_Gas_Energy',GasEnergy,'Time',time);
        load handel; sound(y,Fs)
end