	//===========================================
// Function : some configs to generator the 
//						data_in stimulus
// FileName	: rc6_env_pkg.sv
// Coder    : SingularityKChen
// Edition	: Edit 3
// Date     : DEC 11/2018
//						DEC 14/2018
//						DEC 16/2018
//===========================================
package rc6_env_pkg;
	`include "rc6_coverage.sv"
	class rc6_stimulus_method;
		rand bit [127 : 0] rc6_datain;
		bit [127 : 0] rc6_dataout;
		int rand_times;
	endclass : rc6_stimulus_method

	class stimulus_generator;
		mailbox #(rc6_stimulus_method) fifo;
		bit stop = 0;

		task generate_stimulus();
			rc6_stimulus_method tmp;
			forever begin : random_tmp
				if(~stop) begin
					tmp = new;
					tmp.randomize();
					fifo.put(tmp);//put out the datain and dataout
					$display("time:% t % m generator send out a stimulus:% h",$time(), tmp.rc6_datain);
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

	class rc6_scoreboard;
		mailbox #(rc6_stimulus_method) fifo_score;
		rc6_stimulus_method sco;
		rc6_coverage cov;
		reg test_done;//whether the test were done

		function sc_new (mailbox #(rc6_stimulus_method) fifo_sco);
			fifo_score = fifo_sco;
			test_done = 0;
			cov = new;
		endfunction : sc_new

		task run();
			fork
				forever begin
					fifo_score.get(sco);//receive the data from driver
					check_data();
					$display("time:% t % m scoreboard get a stimulus: % h",$time(), fifo_score);
					cov.fifo_cov.put(sco);//send it to coverage fuction
					test_done = 1;//need to add this signal to count the times
				end
				cov.run();
			join

		endtask : run

		local function void check_data ();
			sco.rand_times += 1;
			if(sco.rand_times >= limit) begin
				test_done = 1;
				$display("time:% t % m compare successfully",$time());
			end
		endfunction : 

	endclass : rc6_scoreboard
endpackage

