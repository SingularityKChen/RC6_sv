//===========================================
// Function : The top module of the testbench
// FileName	: rc6_testbench_top.sv
// Coder    : SingularityKChen
// Edition	: edit 1
// Date     : DEC 11/2018
//===========================================
module top_class_based;
	import rc6_env_pkg::*;
	`include "rc6_interface.sv"
	`include "rc6_driver.sv"
	`include "rc6_monitor.sv"
	`include "rc6_env.sv"
	`include "rc6_coverage.sv"
	bit [127 : 0] rc6_datain, rc6_dataout;
	bit clk, reset, zset;
	//rc6_top dut()    **connectted to the interface

	rc6_env env;
	//bind dut
	initial begin : 
		//env = new();
		fork
			//cr.run();
		join_none
		//env.execute();
		$stop;
	end

endmodule