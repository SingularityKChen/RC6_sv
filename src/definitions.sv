//===========================================
// Function : Some basic definitions
// Coder    : SingularityKChen
// Date     : DEC 09/2018
//===========================================

//===========================================
interface main_port (input wire clk, clk_in, sta_in, data_in, reset, zset,
	output wire clk_out, sta_out, data_put);
	logic clk, reset, zset, clk_out, sta_out, data_put, clk_in, sta_in, data_in;
	logic [127 : 0] datain, dataout, data_back, data_out;
	function automatic [31 : 0] lshitf (input logic [31 : 0] datain,
		input logic [4 : 0] shiftnum);
		logic [31 : 0] result;
		result = datain;
		if (shiftnum[4] == 1)
			result = {result[15 : 0], result[31 : 16]};
		if (shiftnum[3] == 1)
			result = {result[23 : 0], result[31 : 24]};
		if (shiftnum[2] == 1)
			result = {result[27 : 0], result[31 : 28]};
		if (shiftnum[1] == 1)
			result = {result[29 : 0], result[31 : 30]};
		if (shiftnum[0] == 1)
			result = {result[30 : 0], result[31]};
		return result;
	endfunction : lshitf
	//===========================================

	//===========================================
	function automatic [31 : 0] rshitf (input logic [31 : 0] datain,
		input logic [4 : 0] shiftnum);
		logic [31 : 0] result;
		result = datain;
		if (shiftnum[4] == 1)
			result = {result[15 : 0], result[31 : 16]};
		if (shiftnum[3] == 1)
			result = {result[7 : 0], result[31 : 8]};
		if (shiftnum[2] == 1)
			result = {result[3 : 0], result[31 : 4]};
		if (shiftnum[1] == 1)
			result = {result[1 : 0], result[31 : 2]};
		if (shiftnum[0] == 1)
			result = {result[0], result[31 : 1]};
		return result;
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
	function automatic [127 : 0] rfunct (input logic [127 : 0] datain,
		input logic [31 : 0] key1, key2,
		input logic enc);
		logic [127 :0] dataout;
		logic [31 : 0] a, b, c, d, t, u;
		logic [63 : 0] temp1, temp2;
		parameter shiftn = 5'b00101;
		begin : rfunct_main
			assert ($isunknown(enc)) else $error("enc = x");//if enc=x,then error
			if(enc) begin : abcd_1
				a = datain[31 : 0];
				b = datain[63 : 32];
				c = datain[95 : 64];
				d = datain[127 : 96];
			end : abcd_1
			else begin : abcd_0
				a = datain[95 : 64];
				b = datain[31 : 0];
				c = datain[63 : 32];
				d = datain[127 : 96];
			end : abcd_0
			temp1 = (b * 2 + 1) * b;
			temp2 = (d * 2 + 1) * d;
			t = lshitf(temp1[31 : 0], shiftn);
			u = lshitf(temp2[31 : 0], shiftn);
			a = afunct(a, key1, t, u, enc);
			c = cfunct(c, key2, t, u, enc);
			unique if(enc == 1) dataout = {a, d, c, b};
			else if(enc == 0) dataout = {d, c, b, a};
			return dataout;
		end : rfunct_main
	endfunction : rfunct
	//===========================================
	modport  DATAOUT(
		output clk_out, sta_out, data_put,
		input clk, reset, data_back
		);
	modport DATAIN (
		input clk_in, sta_in, data_in, clk,
		output data_out
		);
	modport RC6TOP (
		import function rfunct(input logic [127 : 0] datain,
		input logic [31 : 0] key1, key2,
		input logic enc),
		input clk, reset, zset, datain,
		output dataout
	);
	`ifndef SYNTHESIS
		main_portMethod Method;
	`endif
endinterface

