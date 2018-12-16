//===========================================
// Function : 
// FileName	: rc6_env.sv
// Coder    : SingularityKChen
// Edition	: Edit 1
// Date     : DEC 16/2018
//===========================================
class rc6_env;
	stimulus_generator din;//datain
	mailbox #(rc6_stimulus_method) dr_env, mo_env; //
	rc6_driver dv;
	rc6_monitor mo;
	rc6_scoreboard sb;

	task excute();
		fork
			din.generate_stimulus();
			dv.run();
			mo.run();
			sb.run();
			terminate;
		join_any
	endtask : excute

	task terminate();
		fork
			begin 
				@(posedge sb.test_done);
				din.stop_stimulus_generation();
				$display("TEST FINISHED!");
			end
			begin 
				chech_coverage();
			end
		join
	endtask : terminate

	function env_new (virtual rc6_dut_pins_if pn);
		dr_env = new;
		mo_env = new;
		dv = dr_new(pn);
		mo = mo_new(pn);
		sb = sc_new(mo_env);
		din.fifo = dr_env;
		dv.get_random_data = dr_env;
		mo.monitor_random_data = mo_env;
	endfunction : env_new

	task terminate();
		forever
		begin 
			if( $get_coverage() == 100) begin
				repeat (3) @ (posedge dut_vf.clk);
				$display("FINAL COVERAGE REPORT IS % d %%",sb.cov.rc6_cover.get_inst_coverage());
			end
		end
	endtask : terminate
endclass : rc6_env