//// TODO
// Test

module butterfly_unit(clk, a_in, b_in, twiddle_factor, a_out, b_out);

// Assigning ports as input/ouput
input clk;
input [63:0] a_in, b_in;
input [31:0] twiddle_factor;
output [63:0] a_out, b_out;

// Twiddle Factor 1 approximation
wire [31:0] twiddle_factor_real = (twiddle_factor[31:16] == 16'h7fff) ? 32'h00010000 : {{16{twiddle_factor[31]}}, twiddle_factor[30:16], 1'b0};
wire [31:0] twiddle_factor_imaginary = (twiddle_factor[15:0] == 16'h7fff) ? 32'h00010000 : {{16{twiddle_factor[15]}}, twiddle_factor[14:0], 1'b0};

// Multiplier connections
wire [63:0] product;
multiplier complex_twiddle_xb(
	.clk(clk),
	.ar(b_in[63:32]),
	.ai(b_in[31:0]),
	.br(twiddle_factor_real),
	.bi(twiddle_factor_imaginary),
	.pr(product[63:32]),
	.pi(product[31:0])
	);

// Delay connections
wire [63:0] d_a_in;
clock_delay #(64, 7) multiplier_delay(
	.clk(clk),
	.data(a_in),
	.clr(1'b0),
	.q(d_a_in)
	);

// Adder connections
adder a_out_real_adder(
	.clk(clk),
	.a(d_a_in[63:32]),
	.b(product[63:32]),
	.s(a_out[63:32])
	);
adder a_out_imag_adder(
	.clk(clk),
	.a(d_a_in[31:0]),
	.b(product[31:0]),
	.s(a_out[31:0])
	);

// Subtractor connections
subtractor b_out_real_sub(
	.clk(clk),
	.a(d_a_in[63:32]),
	.b(product[63:32]),
	.s(b_out[63:32])
	);
subtractor b_out_imag_sub(
	.clk(clk),
	.a(d_a_in[31:0]),
	.b(product[31:0]),
	.s(b_out[31:0])
	);

endmodule 
