`include "rc6_top.sv"
interface main_portMethod ();

endinterface

module test;
	task automatic randomrc6(inout seed);
initial begin : clock_block
	# 0 clk = 0; reset = 0;
	# 5 reset = 1;
	# 5 clk = 1;
	# 5 reset = 0; clk = 0;
	forever begin 
		# 5 clk = 1;
		# 5 clk = 0;
	end
end : clock_block

initial begin : ENCRYPT_DECRYPT
	# 0 zset = 1;
	# 200 zset = 0;
end : ENCRYPT_DECRYPT

initial begin : data_creater
	data
end : data_creater
end
endmodule