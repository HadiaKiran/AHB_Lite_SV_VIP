# AHB-Lite-Slave-VIP

## TestBench Architecture:

![image](https://user-images.githubusercontent.com/71690787/156921559-75416eec-b76a-4bb9-a7d6-ad0e8460191f.png)

## TestBench Components
* Transaction Class
* Generator Class
* Interface
* Driver Class
* Monitor Class
* Scoreboard Class
* Environment Class
* Test
* TestBench Top

### Transaction Class
* Fields required to generate the stimulus are declared in the transaction class.
* Transaction class can also be used as a placeholder for the activity monitored by the monitor on DUT signals.
* So, the first step is to declare the Fields‘ in the transaction class.

### Generator Class
 Generator class is responsible for:
* Generating the stimulus by randomizing the transaction class
* Sending the randomized class to driver

### Interface:
* Interface will group the signals, specifies the direction (Modport) and Synchronize the signals(Clocking Block).

### Driver Class
 Driver class is responsible for:
* receive the stimulus generated from the generator and drive to DUT by assigning transaction class values to interface signals.

### Monitor Class
* Samples the interface signals and converts the signal level activity to the transaction level.
* Send the sampled transaction to Scoreboard via Mailbox.

### Scoreboard Class
* Scoreboard receives the sampled packet from monitor and compares the results.

### Environment
* Environment is container class contains Mailbox, Generator, Driver, Monitor and Scoreboard.

### Test
Test code is written with the program block.
The test is responsible for:
* Creating the environment.
* Configuring the testbench i.e, setting the type and number of transactions to be generated.
* Initiating the stimulus driving.

### TestBench Top
* This is the topmost file, which connects the DUT and TestBench.
* TestBench top consists of DUT, Test and Interface instances.
* The interface connects the DUT and TestBench.

## Supported Simulators & Tools
- [x] Aldec Riviera Pro 2020.04
- [x] Mentor Questa 2021.3
- [x] Synopsys VCS 2020.03

## Tests Included
- [x] Single Burst
- [x] Incremental Burst of Undefined Length (INCR)
- [x] INCR & WRAP Tests (4,8,16 Beats)

## How to run a test

1. Change contraints in the `transaction.sv` file according to the case you want to check.
2. Comment/uncomment tests in the "env.sv" file.
3. You can change the number of transactions to be run from the test class file by changing count value.


