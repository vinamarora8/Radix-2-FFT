module clock_delay(clk, data, q);

// Parameter for width and delay generalization
parameter width=1;
parameter cycles=1;

// Assigning ports as in/out
input clk;
input [width-1 : 0] data;
output [width-1 : 0] q;

// Instantiate the register train
reg [width-1 : 0] D[0 : cycles-1];

// Initialize this train to 0
generate
	genvar i;
	for (i=0; i < cycles; i=i+1)
	begin : gen1
		initial
			D[i] = {width{1'b0}};
	end
endgenerate

// Connect outputs
assign q = D[cycles-1][width-1 : 0];

// The Shifting part:
generate
	for (i=cycles-1; i>0; i=i-1)
	begin : gen2
		always @(posedge clk)
			D[i] = D[i-1];
	end
endgenerate

always @(posedge clk)
	D[0] = data;

endmodule

