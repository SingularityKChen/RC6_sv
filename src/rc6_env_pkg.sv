//===========================================
// Function : some configs to generator the 
//						data_in stimulus
// FileName	: rc6_env_pkg.sv
// Coder    : SingularityKChen
// Edition	: edit 1
// Date     : DEC 11/2018
//===========================================
package rc6_env_pkg;
	class rc6_stimulus_method;
		rand bit [127 : 0] rc6_datain;
		bit [127 : 0] rc6_dataout;
	endclass : rc6_stimulus_method

	class stimulus_generator;
		mailbox #(rc6_stimulus_method) fifo;
		int id;
		bit stop = 0;

		function new_st (int id_i);
			id = id_i;
		endfunction

		task generate_stimulus;
			stimulus_generator tmp;
			forever begin : random_tmp
				if(~stop) begin
					tmp = new_st;
					tmp.randomize();
					fifo.put(tmp);
					//$display("time:% 0d generator % 0d send out a stimulus:% b",$time(), id, tmp);
				end
				else
					break;
				end
			end : random_tmp
		endtask : generate_stimulus 

		task stop_stimulus_generation();
			stop = 1;
		endtask : stop_stimulus_generation
	endclass : sitmulus_generator

endpackage

