//===========================================
// Function : ENCRYPT AND DECRYPT OF RC6
// FileName	: rc6_top.sv
// Coder    : SingularityKChen
// Edition	: Edit 3
// Date     : DEC 09/2018
//						DEC 13/2018
//						DEC 16/2018
//===========================================
module RC6_TOP (main_port.rc6 rc);
logic [4 : 0] kadder;
logic [63 : 0] kout;
logic [127 : 0] data,datain;
logic [31 : 0] a,b,c,d;
enum bit [4 : 0]{s0 = 5'b00001,
								s1 = 5'b00010,
								s2 = 5'b00100,
								s3 = 5'b01000,
								s4 = 5'b10000} State;
//rom_using_file i4 (.address(kadder), .q(kout));
DES_ROM ROM_use (.CLK(rc.clk), .Q(kout), .CEN(1), .A(kadder));//set CEN=1
always_ff @(posedge rc.clk or negedge rc.reset) begin
	if(~rc.reset) State <= s0;
	else begin
		unique case (State)
		s0: begin
			State <= s1;
			datain <= rc.trans_rc6;
			if(rc.zset == 1) kadder <= 5'b00000;
			else kadder <= 5'b10101;
			a = datain[31 : 0];
			b = datain[63 : 32];
			c = datain[95 : 64];
			d = datain[127 : 96];
		end // s0:
		s1: begin
			State <= s2;
			if(rc.zset == 1) begin
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
		end // s1:
		s2: begin
			State <= s3;
			data <= rc.rfunct(data, kout[63 : 32], kout[31 : 0], rc.zset);
			if(rc.zset == 1) kadder <= kadder + 1;
			else kadder <= kadder - 1;
		end // s2:
		s3: begin
			if(rc.zset == 1) begin
				/* code */
				if(kadder < 21) State <= s2;
				else State <= s4;
			end
			else begin 
				if(kadder > 0) State <= s2;
				else State <= s4;
			end
		end // s3:
		s4: begin 
			if(rc.zset == 1) begin
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
			rc.trans_real <= {a, b, c, d};
		end // s4:
		endcase
	end // else
end
endmodule	
