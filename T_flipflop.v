module T_flipflop(clk, T, p, c, q);

// Assigning ports as input/output
input clk, T, p, c;
output reg q;

// Initializing register
initial q = 1'b0;

// T-flipflop action
always @(posedge clk)
begin
	if(~p)
		q = 1'b1;
	else if(~c)
		q = 1'b0;
	else if(T)
		q = ~q;
	
end

endmodule 