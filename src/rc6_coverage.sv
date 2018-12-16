//===========================================
// Function : The coverage module of the testbench
// FileName	: rc6_coverage.sv
// Coder    : SingularityKChen
// Edition	: Edit 3
// Date     : DEC 11/2018
//						DEC 14/2018
//						DEC 16/2018
//===========================================
class rc6_coverage;
	mailbox #(rc6_stimulus_method) fifo_cov;
	rc6_stimulus_method dt;
	bit [127 : 0] data_in, data_out;

	covergroup rc6_cover;
		cp_in : coverpoint data_in{
		bins a_in = {[31 : 0]};
		bins b_in = {[63 : 32]};
		bins c_in = {[95 : 64]};
		bins d_in = {[127 : 96]};
		}
		cp_out : coverpoint data_out{
		bins a_out = {[31 : 0]};
		bins b_out = {[63 : 32]};
		bins c_out = {[95 : 64]};
		bins d_out = {[127 : 96]};
		}
		//inxout : cross cp_in, cp_out;
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
