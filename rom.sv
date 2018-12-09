module rom_using_file (
	input logic [4 : 0] address,
	output logic [63 : 0] q	
);
reg [4 : 0] mem [63 : 0];
assign q = mem[address];
always_comb
begin 
	$readmemb("memory.list", mem);
end
endmodule