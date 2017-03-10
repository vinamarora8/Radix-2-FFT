//// TODO
// Test

module address_gen_unit(start_ff, clk, mema_address, memb_address, twiddle_address, mem_write, fft_done);

// Assigning ports as input/output
input start_ff;
output [4:0] mema_address;
output [4:0] memb_address;
output [3:0] twiddle_address;
output mem_write;
output fft_done;

// Clear Hold wire
wire clear_hold;

// Index counter connections
wire [3:0] index_val;
wire index_counter_cout;
wire hold_write;
counter_4b index_counter(
	.clk(clk),
	.sclr(hold_write | clear_hold),
	.out(index_val),
	.cout(index_counter_cout)
	);

// Clock delay connections
wire [4:0] jx2;
clock_delay #(5, 1) wait_for_incrementer(
	.clk(clk),
	.data({index_val, 1'b0}),
	.q(jx2)
	);

// Incrementer connections
wire [4:0] jx2_1;
incrementer inc_index_before_rotation(
	.clk(clk),
	.din({index_val, 1'b0}),
	.clr(clear_hold),
	.dout(jx2_1)
	);

// Level counter connections
wire level_counter_clk;
D_latch level_counter_clk_latch(
	.clk(clk),
	.d(index_counter_cout),
	.p(1'b1),
	.c(1'b1),
	.q(level_counter_clk)
	);
wire [2:0] i;
wire level_counter_cout;
counter_3bm5 level_counter(
	.clk(level_counter_clk),
	.clr(clear_hold),
	.out(i),
	.cout(level_counter_cout)
	);
// Level counter delay connections
wire [2:0] delayed_i;
clock_delay #(3, 1) level_counter_delay(
	.clk(clk),
	.data(i),
	.q(delayed_i)
	);

// MemA_address calculator block
rotate_left_5b mema_address_calculator(
	.clk(clk),
	.din(jx2),
	.S(delayed_i),
	.clr(clear_hold),
	.dout(mema_address)
	);

// MemB_address calculator block
rotate_left_5b memb_address_calculator(
	.clk(clk),
	.din(jx2_1),
	.S(delayed_i),
	.clr(clear_hold),
	.dout(memb_address)
	);

// Twiddle Factor address calculator connections
wire [3:0] mask;
right_shift #(4) twiddle_factor_mask_generator(
	.clk(clk),
	.s_in(1'b1),
	.clr(clear_hold),
	.dout(mask)
	);
assign twiddle_address = mask & index_val;

// Write hold counter connections
wire write_hold_counter_cout;
wire donot_hold_write = ~hold_write;
counter_4b write_hold_counter(
	.clk(clk),
	.sclr(donot_hold_write),
	.cout(write_hold_counter_cout)
	);

// Write hold controller connections
sync_SR_latch write_hold_controller(i
	.clk(clk),
	.s(index_counter_cout),
	.r(write_hold_counter_cout),
	.p(1'b1),
	.c(1'b1),
	.q(hold_write)
	);

// Start_FFT pulse connections
wire d_start_fft;
wire dd_start_fft;
D_latch start_fft_delay1(
	.clk(clk),
	.d(start_fft),
	.p(1'b1),
	.c(1'b1),
	.q(d_start_fft)
	);
D_latch start_fft_delay2(
	.clk(clk),
	.d(d_start_fft),
	.p(1'b1),
	.c(1'b1),
	.q(dd_start_fft)
	);
wire start_fft_pulse = d_start_fft & (~dd_start_fft);

// Start/Stop controller
wire running;
sync_SR_latch(
	.clk(clk),
	.s(start_fft_pulse),
	.r(index_counter_cout & level_counter_cout),
	.p(1'b1),
	.c(1'b1),
	.q(running)
	);

// Clear_hold delay connections
wire inverted_start_fft_pulse = ~start_fft_pulse;
wire d_inv_running;
wire dd_inv_running;
wire ddd_inv_running;
D_latch clear_delay1(
	.clk(clk),
	.d(~running),
	.p(inverted_start_fft_pulse),
	.c(1'b1),
	.q(d_inv_running)
	);
D_latch clear_delay2(
	.clk(clk),
	.d(d_inv_running),
	.p(inverted_start_fft_pulse),
	.c(1'b1),
	.q(dd_inv_running)
	);
D_latch clear_delay3(
	.clk(clk),
	.d(dd_inv_running),
	.p(1'b1),
	.c(1'b1),
	.q(ddd_inv_running)
	);
D_latch clear_delay4(
	.clk(clk),
	.d(ddd_inv_running),
	.p(1'b1),
	.c(1'b1),
	.q(clear_hold)
	);

// Mem write delay connections
wire d_mem_write;
D_latch mem_write_delay1(
	.clk(clk),
	.d(donot_hold_write & running),
	.p(1'b1),
	.c(~dd_inv_running),
	.q(d_mem_write)
	);
D_latch mem_write_delay2(
	.clk(clk),
	.d(d_mem_write),
	.p(1'b1),
	.c(~dd_inv_running),
	.q(mem_write)
	);

// FFT Done connections
assign fft_done = clear_hold & (~running);

endmodule 
