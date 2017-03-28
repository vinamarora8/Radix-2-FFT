module mem_check(clk, start_comp, mema_data, memb_data, mem_address, q, comp_done);

//Assiging ports as in/out
input clk;
input start_comp;
input [63:0] mema_data, memb_data;
output [4:0] mem_address;
output q, comp_done;

// Start Pulse connections
wire d_start_comp;
D_latch start_comp_delay(
	.clk(clk),
	.d(start_comp),
	.p(1'b1),
	.c(1'b1),
	.q(d_start_comp)
	);
wire start_pulse = start_comp & (~d_start_comp);

// Run controller connections
wire running;
wire address_counter_cout;
sync_SR_latch run_controller(
	.clk(clk),
	.s(start_pulse),
	.r(address_counter_cout),
	.p(1'b1),
	.c(1'b1),
	.q(running)
	);

// Address counter connections
counter_5b address_counter(
	.clk(clk),
	.sclr(~running),
	.out(mem_address),
	.cout(address_counter_cout)
	);

// Comparator latch connections
sync_SR_latch comp_latch(
	.clk(clk),
	.s(start_pulse),
	.r(~(mema_data == memb_data)),
	.p(~start_pulse),
	.c(1'b1),
	.q(q)
	);

// Comp_Done connections
wire d_running;
clock_delay #(1, 3) comp_done_delay(
	.clk(clk),
	.data(running),
	.clr(1'b0),
	.q(d_running)
	);
assign comp_done = ~(running | d_running);

endmodule 
