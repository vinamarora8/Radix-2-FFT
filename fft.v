module fft(clk, start_fft, fft_done, mem_address, mem_data);

// Assigning ports as input/output
input clk;
input start_fft;
input [4:0] mem_address;
output fft_done;
output [63:0] mem_data;

// AGU connections
wire bank_select;
wire [4:0] mema_address, memb_address;
wire [3:0] twiddle_address;
wire mem_write;
address_gen_unit address_generator(
	.clk(clk),
	.start_fft(start_fft),
	.mema_address(mema_address),
	.memb_address(memb_address),
	.twiddle_address(twiddle_address),
	.mem_write(mem_write),
	.fft_done(fft_done),
	.bank_select(bank_select)
	);

// Twiddle Factor ROM connections
//wire [31:0] d_twiddle_factor;
wire [31:0] twiddle_factor;
twiddle_factor_ROM twiddle_factors(
	.clka(clk),
	.addra(twiddle_address),
	.douta(twiddle_factor)
	);

// Butterfly Unit connections
wire [63:0] a_in, b_in;
wire [63:0] a_out, b_out;
butterfly_unit butterfly(
	.clk(clk),
	.a_in(a_in),
	.b_in(b_in),
	.twiddle_factor(twiddle_factor),
	.a_out(a_out),
	.b_out(b_out)
	);

//// Memory connections
// Taking care of write delay
wire [4:0] d_mema_address, d_memb_address;
wire d_mem_write;
clock_delay #(5, 10) mema_address_delay(
	.clk(clk),
	.data(mema_address),
	.clr(1'b0),
	.q(d_mema_address)
	);
clock_delay #(5, 10) memb_address_delay(
	.clk(clk),
	.data(memb_address),
	.clr(1'b0),
	.q(d_memb_address)
	);
clock_delay #(1, 10) mem_write_delay(
	.clk(clk),
	.data(mem_write),
	.clr(1'b0),
	.q(d_mem_write)
	);

// Connections to memory_2_bank
wire [4:0] modified_addressa = (fft_done) ? mem_address : mema_address;
memory_2_bank main_mem(
	.clk(clk),
	.select((~bank_select) | fft_done),
	.write_enable(d_mem_write),
	.addw_1(d_mema_address),
	.addw_2(d_memb_address),
	.addr_1(modified_addressa),
	.addr_2(memb_address),
	.din_1(a_out),
	.din_2(b_out),
	.dout_1(a_in),
	.dout_2(b_in)
	);
assign mem_data = a_in;

endmodule
