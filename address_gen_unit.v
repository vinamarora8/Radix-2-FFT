//// TODO
// Clear_Hold connections
// Mem_write delay connections
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
wire [4:0] 2j;
clock_delay #(5, 1) wait_for_incrementer(
	.clk(clk),
	.data({index_val, 1'b0}),
	.q(2j)
	);

// Incrementer connections
wire [4:0] 2j_1;
incrementer inc_index_before_rotation(
	.clk(clk),
	.din({index_val, 1'b0}),
	.clr(clear_hold),
	.dout(2j_1)
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
	.data(i);
	.q(delayed_i)
	);

// MemA_address calculator block
rotate_left_5b mema_address_calculator(
	.clk(clk),
	.din(2j),
	.S(delayed_i),
	.clr(clear_hold),
	.dout(mema_address)
	);

// MemB_address calculator block
rotate_left_5b memb_address_calculator(
	.clk(clk),
	.din(2j_1),
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
	.clk(clk),<F12>
	.s(start_fft_pulse),
	.r(index_counter_cout & level_counter_cout),
	.p(1'b1),
	.c(1'b1),
	.q(running)
	);
