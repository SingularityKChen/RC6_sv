//===========================================
// Function : The monitor module who receive
//						the data from rc6 module and 
//						then send it to the scoreboard
// FileName	: rc6_monitor.sv
// Coder    : SingularityKChen
// Edition	: Edit 2
// Date     : DEC 14/2018
// 						DEC 16/2018
//===========================================
class rc6_monitor;
	virtual main_port.tb dut_vf;
	mailbox #(rc6_stimulus_method) monitor_random_data;

	function mo_new (virtual main_port.tb dut_vf);
		dut_vf = dut_v;
	endfunction : mo_new

	function rc6_stimulus_method pin2transaction();
		rc6_stimulus_method transcation = new;
		transcation.rc6_dataout = dut_vf.data_out;
	endfunction : 
endclass : rc6_monitor  
