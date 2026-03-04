function [yearPrices,yearSaving,yearEnergy] = findBestDay()
    global date % allows transmission of new date for each iteration
    
    daysInYear = 366; % Remember February 29th!
    days = calculateYearDates(daysInYear); % local function preallocates dates
    
    % Preallocation of matrix sizing
    unshiftedValue = zeros([daysInYear 1]);
    shiftedValue = zeros([daysInYear 1]);
    time = strings(daysInYear,1);
    saving = zeros([daysInYear 1]);
    energyUse = zeros([daysInYear 1]);
    
    %% Main Function
    for i = 1:daysInYear % run for the whole year! 
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
        disp(string(date.start) + ' has completed successfully!');
    end
    yearPrices = struct('Shifted_Value',shiftedValue,'Unshifted_Value',unshiftedValue,'Time',time); 
    yearSaving = saving;
    yearEnergy = energyUse;
    
    % It worked! Yippee!
    load handel; sound(y,Fs)
end
function days = calculateYearDates(daysInYear)
global year
    % In order to let the APIs run, strings of dates are used instead of
    % datetimes. This could certainly have been improved.
    dayNum = [31,29,31,30,31,30,31,31,30,31,30,31]; 
    y = year;
    nexty = string(str2double(y)+1);
    p = 1; % counting variable
    
    % Preallocation for efficiency
    start = strings([daysInYear 1]);
    finish = strings([daysInYear 1]);
    ss = strings([daysInYear 1]);
    se = strings([daysInYear 1]);

    % Writing dates to array
    for k = 1:12
         for i = 1:dayNum(k) 
            if i < dayNum(k) 
                    start(p,1) = append(y,'-',pad(string(k),2,'left','0'),'-',pad(string(i),2,'left','0'),'T00:00:00Z');
                    finish(p,1) = append(y,'-',pad(string(k),2,'left','0'),'-',pad(string(i+1),2,'left','0'),'T23:30:00Z');
                    ss(p,1) = append(y,'-',pad(string(k),2,'left','0'),'-',pad(string(i),2,'left','0'));
                    se(p,1) = append(y,'-',pad(string(k),2,'left','0'),'-',pad(string(i+1),2,'left','0'));
                    p = p+1;
            else
                if k < 12
                    start(p,1) = append(y,'-',pad(string(k),2,'left','0'),'-',pad(string(i),2,'left','0'),'T00:00:00Z');
                    finish(p,1) = append(y,'-',pad(string(k+1),2,'left','0'),'-',pad(string(1),2,'left','0'),'T23:30:00Z');
                    ss(p,1) = append(y,'-',pad(string(k),2,'left','0'),'-',pad(string(i),2,'left','0'));
                    se(p,1) = append(y,'-',pad(string(k+1),2,'left','0'),'-',pad(string(1),2,'left','0'));
                    p = p+1;
                else
                        
                    start(p,1) = append(y,'-',pad(string(12),2,'left','0'),'-',pad(string(31),2,'left','0'),'T00:00:00Z');
                    finish(p,1) = append(nexty,'-',pad(string(1),2,'left','0'),'-',pad(string(1),2,'left','0'),'T23:30:00Z');
                    ss(p,1) = append(y,'-',pad(string(12),2,'left','0'),'-',pad(string(31),2,'left','0'));
                    se(p,1) = append(nexty,'-',pad(string(1),2,'left','0'),'-',pad(string(1),2,'left','0'));
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