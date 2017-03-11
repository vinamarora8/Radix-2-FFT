module counter_3bm5 (
	input clk,
	input sclr,
	output [2:0] out,
	output cout
	);
	
	// This module is a 4-bit counter with synchronous clear

	// Instantiate register that will count
	reg [3:0] count;

	// Initialize the register
	initial
		count = 4'b0000;

	// Assign outputs
	assign out = count[2:0];
	assign cout = count[3];

	// State machine:
	always @(posedge clk)
	begin
		// Synchronous clear and Modulus
		if (sclr == 1'b1)
			count = 4'b0000;
		// Cout management
		else if (count == 4'b0100)
		begin
			count = 4'b1000;
		end
		// Else count up
		else
			count = count + 1'b1;
	end

endmodule

