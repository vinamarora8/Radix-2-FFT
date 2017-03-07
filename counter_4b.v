module counter_4b (
	input clk,
	input sclr,
	output [3:0] out,
	output cout
	);
	
	// This module is a 4-bit counter with synchronous clear

	// Instantiate register that will count
	reg [4:0] count;

	// Initialize the register
	initial
		count = 5'b00000;

	// Assign outputs
	assign out = count[3:0];
	assign cout = count[4];

	// State machine:
	always @(posedge clk)
	begin
		// Synchronous clear
		if (sclr == 1'b1)
			count = 5'b00000;
		// Else count up
		else
			count = count + 1'b1;
	end

endmodule

