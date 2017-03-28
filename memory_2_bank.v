//// TODO
// Test

module memory_2_bank(clk, select, write_enable, addw_1, addw_2, addr_1, addr_2, din_1, din_2, dout_1, dout_2);

// Assigning ports as input/output
input clk, select, write_enable;
input [4:0] addw_1, addw_2, addr_1, addr_2;
input [63:0] din_1, din_2;
output [63:0] dout_1, dout_2;

//// Connections for memA
// Write to A if select == 1
wire [4:0] addA_1 = (select) ? addw_1 : addr_1;
wire [4:0] addA_2 = (select) ? addw_2 : addr_2;
wire [63:0] doutA_1, doutA_2;
block_RAM_init bank1(
	.clka(clk),
	.clkb(clk),
	.wea((select)&(write_enable)),
	.web((select)&(write_enable)),
	.addra(addA_1),
	.addrb(addA_2),
	.dina(din_1),
	.dinb(din_2),
	.douta(doutA_1),
	.doutb(doutA_2)
	);

//// Connections for memB
// Write to B if select == 0
wire [4:0] addB_1 = (select) ? addr_1 : addw_1;
wire [4:0] addB_2 = (select) ? addr_2 : addw_2;
wire [63:0] doutB_1, doutB_2;
block_RAM	 bank2(
	.clka(clk),
	.clkb(clk),
	.wea((~select)&(write_enable)),
	.web((~select)&(write_enable)),
	.addra(addB_1),
	.addrb(addB_2),
	.dina(din_1),
	.dinb(din_2),
	.douta(doutB_1),
	.doutb(doutB_2)
	);

// Connections for data out
assign dout_1 = (select) ? doutB_1 : doutA_1;
assign dout_2 = (select) ? doutB_2 : doutA_2;

endmodule
