function findBestDay()
    inputData = humanMachineInterface()
    testDataPack = testController()

    for i = 0:364
        inputData.TestCase.begin_date = '2025-01-1T00:00:00Z';
        inputData.TestCase.end_date = '2025-01-2T23:30:00Z';
        inputData.TestCase.begin_date_short = '2025-01-1';
        inputData.TestCase.end_date_short = '2025-01-2';

        [DP,~,~] = optimisedCost();

        disp(max(DP));


end