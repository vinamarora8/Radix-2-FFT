module address_gen_unit(start_fft, clk, mema_address, memb_address, twiddle_address, mem_write, fft_done, bank_select);

// Assigning ports as input/output
input start_fft;
input clk;
output [4:0] mema_address;
output [4:0] memb_address;
output [3:0] twiddle_address;
output mem_write;
output fft_done;
output bank_select;

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
	.clr(clear_hold),
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
wire start_fft_pulse;
counter_3bm5 level_counter(
	.clk(level_counter_clk | start_fft_pulse),
	.sclr(clear_hold),
	.out(i),
	.cout(level_counter_cout)
	);
// Level counter delay connections
wire [2:0] delayed_i;
clock_delay #(3, 1) level_counter_delay(
	.clk(clk),
	.data(i),
	.clr(clear_hold),
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
wire d_level_counter_clk;
clock_delay #(1,1) mask_gen_clk_delay(
	.clk(clk),
	.data(level_counter_clk),
	.clr(clear_hold),
	.q(d_level_counter_clk)
	);
right_shift #(4) twiddle_factor_mask_generator(
	.clk(d_level_counter_clk),
	.s_in(1'b1),
	.clr(clear_hold),
	.dout(mask)
	);
wire [3:0] nd_twiddle_address = mask & index_val;
clock_delay #(4,2) twiddle_coutput_delay_box(
	.clk(clk),
	.data(nd_twiddle_address),
	.clr(clear_hold),
	.q(twiddle_address)
	);

// Write hold counter connections
wire write_hold_counter_cout;
wire donot_hold_write = ~hold_write;
counter_4b write_hold_counter(
	.clk(clk),
	.sclr(donot_hold_write),
	.cout(write_hold_counter_cout)
	);

// Write hold controller connections
sync_SR_latch write_hold_controller(
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
assign start_fft_pulse = d_start_fft & (~dd_start_fft);

// Start/Stop controller
wire running;
sync_SR_latch start_stop_controller(
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
wire mem_write_clear = ~(hold_write || clear_hold);
D_latch mem_write_delay1(
	.clk(clk),
	.d(donot_hold_write & running),
	.p(1'b1),
	.c(mem_write_clear),
	.q(d_mem_write)
	);
D_latch mem_write_delay2(
	.clk(clk),
	.d(d_mem_write),
	.p(1'b1),
	.c(mem_write_clear),
	.q(mem_write)
	);

// FFT Done connections
assign fft_done = clear_hold & (~running);

// Bank Select connections
T_flipflop bank_selector(
	.clk(mem_write),
	.T(1'b1),
	.p(1'b1),
	.c(~clear_hold),
	.q(bank_select)
	);

endmodule 
