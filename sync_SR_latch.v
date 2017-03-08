module sync_SR_latch(clk, s, r, p, c, q);

// Assigning ports as inputs/outputs
input clk, s, r, p, c;
output reg q;

// Initiating registers
initial
	q = 1'b0;

// SR action
always @(posedge clk)
begin
	if (~p)
		q <= 1'b1;
	else if (~c)
		q <= 1'b0;
	else if (s)
		q <= 1'b1;
	else if (r)
		q <= 1'b0;
end

endmodule
