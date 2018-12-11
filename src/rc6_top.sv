//===========================================
// Function : ENCRYPT AND DECRYPT OF RC6
// FileName	: rc6_top.sv
// Coder    : SingularityKChen
// Edition	: edit 1
// Date     : DEC 09/2018
//===========================================
`include "definitions.sv"
`include "rom.sv"
//===========================================
module RC6_TOP (main_port.RC6TOP RC6);
logic kadder;
logic [63 : 0] kout;
logic [127 : 0] data;
logic [31 : 0] a,b,c,d;
typedef enum bit [4 : 0]{s0 = 5'b00001,
								s1 = 5'b00010,
								s2 = 5'b00100,
								s3 = 5'b01000,
								s4 = 5'b10000} State;
always_ff @(posedge RC6.clk or negedge RC6.reset) begin
	if(~RC6.reset) State <= s0;
	else begin
		unique case (State)
		s0: begin
			State <= s1;
			if(RC6.zset == 1) kadder <= 5'b00000;
			else kadder <= 5'b10101;
			rom i1(.address(kadder), .q(kout));
			a = RC6.datain[31 : 0];
			b = RC6.datain[63 : 32];
			c = RC6.datain[95 : 64];
			d = RC6.datain[127 : 96];
		end // s0:
		s1: begin
			State <= s2;
			if(RC6.zset == 1) begin
				b = b + kout[63 : 32];
				d = d + kout[31 : 0];
				kadder <= kadder + 1;
			end
			else begin
				c = c - kout[31 : 0];
				a = a - kout[63 : 32];
				kadder <= kadder - 1;
			end // else
			data = {d, c, b, a};
			rom i1(.address(kadder), .q(kout));
		end // s1:
		s2: begin
			State <= s3;
			data = rfunct(data, kout[63 : 32], kout[31 : 0],RC6.zset);
			if(RC6.zset == 1) kadder <= kadder + 1;
			else kadder <= kadder - 1;
			rom i1(.address(kadder), .q(kout));
		end // s2:
		s3: begin
			if(RC6.zset == 1) begin
				/* code */
				if(kadder < 21) State <= s2;
				else State <= s4;
			end
			else begin 
				if(kadder > 0) State <= s2;
				else State <= s4;
			end
			rom i1(.address(kadder), .q(kout));
		end // s3:
		s4: begin 
			if(RC6.zset == 1) begin
				/* code */
				a = data[31 : 0] + kout[63 : 32];
				b = data[63 : 32];
				c = data[95 : 64] + kout[31 : 0];
				d = data[127 : 96];
			end
			else begin 
				a = data[31 : 0];
				b = data[63 : 32] - kout[63 : 32];
				c = data[95 : 64];
				d = data[127 : 96] - kout[31 : 0];
			end
			RC6.dataout <= {a, b, c, d};
		end // s4:
		endcase
	end // else
end
endmodule	
