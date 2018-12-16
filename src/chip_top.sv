//===========================================
// Function : The top module which connect
//						all modules. 
// FileName	: chip_top.sv
// Coder    : SingularityKChen
// Edition	: Edit 1
// Date     : DEC 16/2018
//===========================================
`include "definitions.sv"
`include "rc6_top.sv"
//`include "rom.sv"
`include "DES_ROM.v"
`include "realtop.sv"
`include "rc6_testbench_top.v"
module chip (
	input logic clk, clk_in, inen, reset, zset, outen,
	input logic [127 : 0] data_in,
	output logic clk_out,
	output logic [127 : 0] data_out);
	//main_port mport(clk, reset, zset, datain, dataout);
	main_port mport(.*);
	RC6_TOP DUT_rc6( mport );
	REAL_TOP DUT_real( mport );
	top_class_based dut_vf( mport );
endmodule