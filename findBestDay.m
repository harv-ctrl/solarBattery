function [yearPrices,yearSaving,yearHeating] = findBestDay()
    global date % allows transmission of new date for each iteration
    days = calculateYearDates(); % local function preallocates dates
    
    % Preallocation of matrix sizing
    unshiftedValue = zeros([365 1]);
    shiftedValue = zeros([365 1]);
    time = strings(365,1);
    saving = zeros([365 1]);
    energyUse = zeros([365 1]);
    
    %% Main Function
    for i = 1:365 % run for the whole year!
        date.start = days.start(i);
        date.end = days.finish(i);
        date.ss = days.ss(i);
        date.se = days.se(i);
        [DP,UP,SP,~,~] = optimisedCost();
        unshiftedValue(i,1) = UP;
        shiftedValue(i,1) = SP;
        saving(i,1) = DP;
        time(i,1) = date.start;
        energyUse(i,1) = calculateEnergy();
    end
    yearPrices = struct('Shifted_Value',shiftedValue,'Unshifted_Value',unshiftedValue,'Time',time); 
    yearSaving = saving;
    yearHeating = energyUse;
    
    % It worked! Yippee!
    load handel; sound(y,Fs)
end
function days = calculateYearDates()
    % In order to let the APIs run, strings of dates are used instead of
    % datetimes. This could certainly have been improved.
    dayNum = [31,28,31,30,31,30,31,31,30,31,30,31];
    p = 1; % counting variable
    
    % Preallocation for efficiency
    start = strings([365 1]);
    finish = strings([365 1]);
    ss = strings([365 1]);
    se = strings([365 1]);

    % Writing dates to array
    for k = 1:12
         for i = 1:dayNum(k) 
            if i < dayNum(k) 
                    start(p,1) = append('2025-',pad(string(k),2,'left','0'),'-',pad(string(i),2,'left','0'),'T00:00:00Z');
                    finish(p,1) = append('2025-',pad(string(k),2,'left','0'),'-',pad(string(i+1),2,'left','0'),'T23:30:00Z');
                    ss(p,1) = append('2025-',pad(string(k),2,'left','0'),'-',pad(string(i),2,'left','0'));
                    se(p,1) = append('2025-',pad(string(k),2,'left','0'),'-',pad(string(i+1),2,'left','0'));
                    p = p+1;
            else
                if k < 12
                    start(p,1) = append('2025-',pad(string(k),2,'left','0'),'-',pad(string(i),2,'left','0'),'T00:00:00Z');
                    finish(p,1) = append('2025-',pad(string(k+1),2,'left','0'),'-',pad(string(1),2,'left','0'),'T23:30:00Z');
                    ss(p,1) = append('2025-',pad(string(k),2,'left','0'),'-',pad(string(i),2,'left','0'));
                    se(p,1) = append('2025-',pad(string(k+1),2,'left','0'),'-',pad(string(1),2,'left','0'));
                    p = p+1;
                else
                        
                    start(p,1) = append('2025-',pad(string(12),2,'left','0'),'-',pad(string(31),2,'left','0'),'T00:00:00Z');
                    finish(p,1) = append('2026-',pad(string(1),2,'left','0'),'-',pad(string(1),2,'left','0'),'T23:30:00Z');
                    ss(p,1) = append('2025-',pad(string(12),2,'left','0'),'-',pad(string(31),2,'left','0'));
                    se(p,1) = append('2026-',pad(string(1),2,'left','0'),'-',pad(string(1),2,'left','0'));
                    p = p+1;
                end
             end
         end
    end
    % Adding to seperate structure
    days.start = start;
    days.finish = finish;
    days.ss = ss;
    days.se = se;
end