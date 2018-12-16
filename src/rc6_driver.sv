//===========================================
// Function : The driver module who receive
//						the radom data from generator
//						and then send it to DUT
// FileName	: rc6_driver.sv
// Coder    : SingularityKChen
// Edition	: Edit 3
// Date     : DEC 11/2018
//						DEC 14/2018
//						DEC 16/2018
//===========================================
class rc6_driver;
	virtual main_port.tb dut_vf;
	mailbox #(rc6_stimulus_method) get_random_data;
	rc6_stimulus_method transaction;

	function dr_new (virtual main_port.tb dut_v);
		dut_vf = dut_v;
	endfunction : dr_new

	task run;
		dut_vf.data_in = 0;
		@(negedge dut_vf.rset)
		forever @(posedge dut_vf.clk)
			if(get_random_data.try_get(transaction)) begin
				dut_vf.data_in = 0;
				$display("time:% t % m driver get a stimulus: % h",$time(), transaction.rc6_datain);
				dut_vf.data_in = transaction.rc6_datain;
				@(posedge dut_vf.clk);
				dut_vf.data_in = 0;
			end
	endtask : run
endclass : rc6_driver	
