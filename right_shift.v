module right_shift(s_in, clk, clr, dout);

parameter width = 4;

// Assigning outputs as input/output
input s_in, clk, clr;
output reg [width-1 : 0] dout;

// Initializing registers
initial
begin
	dout = { width{1'b0} };
end

// Right-Shift action:
// Shifting all the bits, less the last
generate
	genvar i;
	for (i = 0; i<width-1; i = i+1)
	begin : gen1
		always @(posedge clk)
		begin
			// Shift
			dout[i] = dout[i+1];
			// Takes care of synchronous clear
			if (clr)
				dout[i] = 1'b0;
		end
	end
endgenerate

always @(posedge clk)
begin
	// Pull in first bit
	dout[width-1] = s_in;	
	// Takes care of synchronous clear
	if (clr)
		dout[width-1] = 1'b0;
	
end

endmodule
