module counter_5b(
	input clk,
	input sclr,
	output [4:0] out,
	output cout
	);
	
	// This module is a 5-bit counter with synchronous clear

	// Instantiate register that will count
	reg [5:0] count;

	// Initialize the register
	initial
		count = 6'b000000;

	// Assign outputs
	assign out = count[4:0];
	assign cout = count[5];

	// State machine:
	always @(posedge clk)
	begin
		// Synchronous clear
		if (sclr == 1'b1)
			count = 6'b000000;
		// Else count up
		else
			count = count + 1'b1;
	end

endmodule
