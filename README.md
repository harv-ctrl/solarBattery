How to use this repository

This repository works by taking data as specified in the humanMachineInterface() function and using it to calculate various simulation data for components.
To change the code to work for any date, 
1. Open humanMachineInterface() and make changes into the section at the top specified. NOTE: if battery capacity is changed this must also be updated in optimiseCost().
2. To use the app, simply change the desired test day and year in humanMachineInterface() and then run the app displayApp.mlapp
3. To perform whole year optimisation, choose test year in findbestday, then run the whole function. Make sure to run it like this: [yearPrices,yearSaving,yearEnergy] = findBestDay() to save all inputs.

Any questions, email me at me@ferdinandclarke.com

Happy simulating! 
