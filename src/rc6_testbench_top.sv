//===========================================
// Function : The top module of the testbench
// FileName	: rc6_testbench_top.sv
// Coder    : SingularityKChen
// Edition	: Edit 2
// Date     : DEC 11/2018
//						DEC 14/2018
//===========================================
module top_class_based（main_port.tb tebch);
	import rc6_env_pkg::*;
	`include "rc6_interface.sv"
	`include "rc6_driver.sv"
	`include "rc6_monitor.sv"
	`include "rc6_env.sv"
	`include "	chip_top.sv"

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
