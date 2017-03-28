module main(clk, start_sw, unlock, fft_done, done, check_q);

// Assigning ports as in/out
input clk, start_sw, unlock;
output done, check_q, fft_done;

//// Start_sw -> Start conversion
reg lock;
initial lock = 1'b0;

always @(posedge clk)
begin
	if ((~lock) & start_sw)
	begin
		lock = 1'b1;
	end
	else if (lock & unlock)
	begin	
		lock = 1'b0;
	end	
end

wire small_start = (lock) ? 1'b0 : start_sw;
// Extending this start signal
wire d_small_start;
clock_delay #(1,1) start_extension_delay(
	.clk(clk),
	.data(small_start),
	.clr(1'b0),
	.q(d_small_start)
	);

wire start = small_start | d_small_start;

// FFT connections
wire [4:0] fft_mem_address;
wire [63:0] fft_mem_data;
fft radix2_fft_system(
	.clk(clk),
	.start_fft(start),
	.fft_done(fft_done),
	.mem_address(fft_mem_address),
	.mem_data(fft_mem_data)
	);

// Running controller connections
wire running;
wire check_done_pulse;
sync_SR_latch running_controller_latch(
	.clk(clk),
	.s(~fft_done),
	.r(check_done_pulse),
	.p(1'b1),
	.c(1'b1),
	.q(running)
	);

// fft_done_pulse
wire actual_fft_done = fft_done & running;
wire d_actual_fft_done;
D_latch fft_done_delay(
	.clk(clk),
	.d(actual_fft_done),
	.p(1'b1),
	.c(1'b1),
	.q(d_actual_fft_done)
	);
wire fft_done_pulse = actual_fft_done & (~d_actual_fft_done);
wire d_fft_done_pulse;
clock_delay #(1, 5) fft_done_pulse_delay(
	.clk(clk),
	.data(fft_done_pulse),
	.clr(1'b0),
	.q(d_fft_done_pulse)
	);

// mem_check connections
wire [63:0] memb_data;
wire check_done;
mem_check result_checker(
	.clk(clk),
	.start_comp(d_fft_done_pulse),
	.mema_data(fft_mem_data),
	.memb_data(memb_data),
	.mem_address(fft_mem_address),
	.q(check_q),
	.comp_done(check_done)
	);

// Check done pulse connections
wire d_check_done;
D_latch check_done_pulse_delay(
	.clk(clk),
	.d(check_done),
	.p(1'b1),
	.c(1'b1),
	.q(d_check_done)
	);
assign check_done_pulse = check_done & (~d_check_done);

// Check ROM connections
block_RAM_check checking_ROM(
	.clka(clk),
	.addra(fft_mem_address),
	.douta(memb_data)
	);

assign done = ~running;

endmodule
