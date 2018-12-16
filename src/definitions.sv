	//===========================================
// Function : Some basic definitions which 
//						includes some functions and the
//						interface port 
// FileName	: definition.sv
// Coder    : SingularityKChen
// Edition	: Edit 3
// Date     : DEC 09/2018
//						DEC 13/2018
//						DEC 16/2018
//===========================================

//==========================================
interface main_port (clk, clk_in, inen, data_in, reset, zset,clk_out, data_out, outen);
	input logic clk, clk_in, inen, reset, zset, outen;
	input logic [127 : 0] data_in;
	output logic clk_out;
	output logic [127 : 0] data_out;
	logic [127 : 0] trans_real, trans_rc6;

	function automatic [31 : 0] lshitf(input logic [31 : 0] shiftldatain,
		input logic [4 :0] shiftnum);
		logic [31 : 0] result;
		result = shiftldatain;
		if (shiftnum[4])
			result = {result[15 : 0], result[31 : 16]};
		if (shiftnum[3])
			result = {result[23 : 0], result[31 : 24]};
		if (shiftnum[2])
			result = {result[27 : 0], result[31 : 28]};
		if (shiftnum[1])
			result = {result[29 : 0], result[31 : 30]};
		if (shiftnum[0])
			result = {result[30 : 0], result[31]};
		return result;
	endfunction : lshitf
	//===========================================

	//===========================================
	function automatic [31 : 0] rshitf(input logic [31 : 0] shiftrdatain,
		input logic [4 : 0] shiftnum);
		logic [31 : 0] result;
		reg [31 : 0] middle_result;
		result = shiftrdatain;
		if (shiftnum[4])
			result = {result[15 : 0], result[31 : 16]};
		if (shiftnum[3])
			result = {result[7 : 0], result[31 : 8]};
		middle_result = result;//to form the Pipeline.
		if (shiftnum[2])
			middle_result = {middle_result[3 : 0], middle_result[31 : 4]};
		if (shiftnum[1])
			middle_result = {middle_result[1 : 0], middle_result[31 : 2]};
		if (shiftnum[0])
			middle_result = {result[0], middle_result[31 : 1]};
		return middle_result;
	endfunction : rshitf
	//===========================================

	//===========================================
	function automatic [31 : 0] afunct (input logic [31 : 0] datain, s, t, u,
		input logic enc);
		logic [31 : 0] temp;
		logic [31 : 0] result;
		begin : afunct_main
			assert ($isunknown(enc)) else $error("enc = x");//if enc=x,then error
			if(enc) begin : afunct_1
				temp = datain ^ t;
				result = lshitf(temp,u[4 : 0]) + s;
			end : afunct_1
			else begin : afunct_0
				temp = datain - s;
				result = rshitf(temp,u[4 : 0]) ^ t;	
			end : afunct_0
			return result;
		end : afunct_main
	endfunction : afunct
	//===========================================

	//===========================================
	function automatic [31 : 0] cfunct (input logic [31 : 0] datain, s, t, u,
		input logic enc);
		logic [31 : 0] temp;
		logic [31 : 0] result;
		begin : cfunct_main
			assert ($isunknown(enc)) else $error("enc = x");//if enc=x,then error
			if(enc) begin : cfunct_1
				temp = datain ^ u;
				result = lshitf(temp,t[4 : 0]) + s;
			end : cfunct_1
			else begin : cfunct_0
				temp = datain - s;
				result = rshitf(temp,t[4 : 0]) ^ u;	
			end : cfunct_0
			return result;
		end : cfunct_main
	endfunction : cfunct
	//===========================================

	//===========================================
	function automatic [127 : 0] rfunct (input logic [127 : 0] r_datain,
			input logic [31 : 0] key1, key2,
		input logic enc);
		logic [127 :0] r_dataout;
		logic [31 : 0] a, b, c, d, t, u;
		logic [63 : 0] temp1, temp2;
		parameter shiftn = 5'b00101;
		begin : rfunct_main
			assert ($isunknown(enc)) else $error("enc = x");//if enc=x,then error
			if(enc) begin : abcd_1
				a = r_datain[31 : 0];
				b = r_datain[63 : 32];
				c = r_datain[95 : 64];
				d = r_datain[127 : 96];
			end : abcd_1
			else begin : abcd_0
				a = r_datain[95 : 64];
				b = r_datain[31 : 0];
				c = r_datain[63 : 32];
				d = r_datain[127 : 96];
			end : abcd_0
			temp1 = (b * 2 + 1) * b;
			temp2 = (d * 2 + 1) * d;
			t = lshitf(temp1[31 : 0], shiftn);
			u = lshitf(temp2[31 : 0], shiftn);
			a = afunct(a, key1, t, u, enc);
			c = cfunct(c, key2, t, u, enc);
			unique if(enc == 1) r_dataout = {a, d, c, b};
			else if(enc == 0) r_dataout = {d, c, b, a};
			return r_dataout;
		end : rfunct_main
	endfunction : rfunct
	//===========================================
	modport trans (
		input clk_in, reset, inen, data_in, clk, outen, trans_real,
		output data_out, clk_out, trans_rc6
		);
	modport rc6 (
		import function [127 : 0] rfunct
													(input logic [127 : 0] r_datain,
													input logic [31 : 0] key1, key2,
													input logic enc),
		input clk, reset, zset, trans_rc6,
		output trans_real
		);
	modport tb (
		input clk, clk_in, inen, reset, zset, outen, data_in,
		output clk_out,data_out
		);
endinterface

