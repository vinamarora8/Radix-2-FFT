module rotate_left_5b(din, S, clk, clr, dout);

// Assigning ports as input/output
input [4:0] din;
input [2:0] S;
input clk, clr;
output reg [4:0] dout;

// Initializing registers
initial
	dout <= din;

// Rotate action:
always @(posedge clk)
begin
	if (clr)
		dout <= din;
	else if (S == 3'd0)
		dout <= din;
	else if (S == 3'd1)
		dout <= {din[3:0], din[4]};
	else if (S == 3'd2)
		dout <= {din[2:0], din[4:3]};
	else if (S == 3'd3)
		dout <= {din[1:0], din[4:2]};
	else
		dout <= {din[0], din[4:1]};
end

endmodule
