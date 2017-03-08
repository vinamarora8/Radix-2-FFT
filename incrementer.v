module incrementer(din, clk, clr, dout);

// Parameter definition for varying bit-width
parameter width = 5;

// Assigning ports as input/output
input [width-1 : 0] din;
input clk, clr;
output reg [width-1 : 0] dout;

// Initializing registers
initial
	dout <= {{(width-1){1'b0}}, 1'b1};

// Creating instantaneous incremented data
wire [width-1 : 0] dout_buf = din + {{(width-1){1'b0}}, 1'b1};

// Incrementer action:
always @(posedge clk)
begin
	if (clr)
		dout <= {{(width-1){1'b0}}, 1'b1};
	else
		dout <= dout_buf;
end

endmodule
