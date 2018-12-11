//===========================================
// Function : The driver module who receive
//						the radom data from generator
//						and then send it to DUT
// FileName	: rc6_driver.sv
// Coder    : SingularityKChen
// Edition	: edit 1
// Date     : DEC 11/2018
//===========================================
class rc6_driver;
	mailbox #(rc6_stimulus_method) get_random_data;
	rc6_stimulus_method transaction;

	task run();
	
	endtask : run
endclass : rc6_driver1