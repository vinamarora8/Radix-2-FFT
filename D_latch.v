module D_latch(clk, d, p, c, q);

// Assigning ports as input/output
input clk, d, p, c;
output reg q;

// Initializing the output
initial
	q <= 1'b0;

// D-Latch action
always @(posedge clk)
begin
	if (~p)
		q <= 1'b1;
	else if (~c)
		q <= 1'b0;
	else
		q <= d;
end

endmodule 
