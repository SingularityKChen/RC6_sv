# RC6_sv

The SystemVerilog code of an integrated circuit.

**AGENDA**

+ [Description](https://github.com/SingularityKChen/RC6_sv/blob/SingularityKChen-patch-1/README.md#description)

+ [Parameters](https://github.com/SingularityKChen/RC6_sv/blob/SingularityKChen-patch-1/README.md#paremeters)

+ [The structure of DUT](https://github.com/SingularityKChen/RC6_sv/blob/SingularityKChen-patch-1/README.md#the-structure-of-dut)

+ [The structure of TestBench](https://github.com/SingularityKChen/RC6_sv/blob/SingularityKChen-patch-1/README.md#the-structure-of-testbench)

+ [Some Useful References](https://github.com/SingularityKChen/RC6_sv/blob/SingularityKChen-patch-1/README.md#some-useful-references)
***

***
## Description
This is a Digital IC design for encrypt and decrypt for 128-bit data via the RC6 method.
The RTL of this circuit includes definition.sv, rc6_top.sv, rom.sv and memory.list which provides the initial data of Rom.
The testbench includes rc6_testbench.sv, rc6_env_pkg.sv, rc6_driver.sv, rc6_monitor.sv, rc6_coverage.sv.

## Some Important Parameters

### definitions.sv

+ lshift, rshift: Function name. They are related to the shift operation.

+ afunct, cfunct, rfunct: Function name. They are related to the process of RC6 encrypt and decrypt.

+ clk: 1-bit-logic variable. The clock signal from outside the circuit to control the rhythm of the whole circuit.

+ reset: 1-bit-logic variable. The reset or clear signal from outside the circuit. The circuit will be at the initial stage if the signal equals to one.

+ zset:  1-bit-logic variable. It comes from outside and the circuit begins to encrypt data when zset equals to one and to decrypt the data otherwise.

+ datain:  128-bit-logic variable. It is the data that needed to encrypt or decrypt.

+ dataout: 128-bit-logic variable. It is the data after calculating.

+ shiftnum: 5-bit-logic variable. How many times it needs to repeat the process of the shift operation.

+ shiftldatain: 32-bit-logic variable. The data needed to be shift left operation.

+ shiftrdatain: 32-bit-logic variable. The data needed to be shift right operation.

+ result: 32-bit-logic variable. It is the result of each function.

+ enc: 1-bit-logic variable. It is the zset signal inside each function to show the work stage.

### rc6_top.sv

+ chip: Module name. It's the top module of RC6 which declare the modport of the main_port interface, and tell that how to connect the RC6_TOP module.

+ RC6_TOP: Module name. It's the core of this .sv file.

+ i1: Port name. It describes the connecting relationship of the signals between the interface and RC6_TOP.

+ i2: Port name. It describes the connecting relationship of the signals between the Rom and RC6_TOP.

+ clk: 1-bit-logic variable. The clock signal from outside the circuit to control the rhythm of the whole circuit.

+ reset: 1-bit-logic variable. The reset or clear signal from outside the circuit. The circuit will be at the initial stage if the signal equals to one.

+ zset:  1-bit-logic variable. It comes from outside and the circuit begins to encrypt data when zset equals to one and to decrypt the data otherwise.

+ datain:  128-bit-logic variable. It is the data that needed to encrypt or decrypt.

+ dataout: 128-bit-logic variable. It is the data after calculating.

+ kadder: 5-bit-logic array. It's the address number that this circuit needs to read in the Rom.

+ kout: 64-bit-logic variable. It's the data that this circuit needs to encrypt or decrypt.

+ a, b, c, d: 32-bit-logic variable. Some temp variables needed via the process of calculation.

+ State: The type we create to describe the process of calculation.

### rom.sv

+ address: 5-bit-logic array. Each address related to one group of data in the Rom.

+ q: 64-bit-logic variable. The group of data stored in 

+ mem: The 5\*64-bit Rom.

### rc6_testbench.sv

### rc6_env_pkg.sv

### rc6_driver.sv

### rc6_monitor.sv

### rc6_coverage.sv

## The structure of DUT

### definitions.sv

### rc6_top.sv

### rom.sv

## The structure of TestBench

### rc6_testbench.sv

### rc6_env_pkg.sv

### rc6_driver.sv

### rc6_monitor.sv

### rc6_coverage.sv

## Some Useful References 
