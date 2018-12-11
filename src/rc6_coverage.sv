//===========================================
// Function : The coverage module of the testbench
// FileName	: rc6_coverage.sv
// Coder    : SingularityKChen
// Edition	: edit 1
// Date     : DEC 11/2018
//===========================================
class rc6_coverage;
	mailbox #(rc6_stimulus_method) fifo_cov;
	rc6_stimulus_method dt;
	bit [127 : 0] data_in, data_out;

	covergroup rc6_cover;
		coverpoint data_in{}
		coverpoint data_out{}
		cross data_in, data_out;
	endgroup : rc6_cover

	function new_cov();
		rc6_cover = new_cov;
	endfunction : 

	task run;
		forever begin : getmail
			fifo_cov.get(dt);
			data_in = dt.rc6_datain;
			data_out = dt.rc6_dataout;
			rc6_coverage.sample;
		end : getmail
	endtask : run
endclass : rc6_coverage