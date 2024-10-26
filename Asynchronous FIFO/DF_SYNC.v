module DF_SYNC # (parameter BUS_WIDTH = 4)
(
	input wire CLK,
	input wire RST,
	input wire [BUS_WIDTH-1:0] ASYNC,
	output wire [BUS_WIDTH-1:0] SYNC
);

reg [BUS_WIDTH-1:0] sync_flop1;
reg [BUS_WIDTH-1:0] sync_flop2;

always @(posedge CLK or negedge RST) begin
	if(~RST) begin
		sync_flop1 <= 'b0;
        sync_flop2 <= 'b0;
	end
	else begin
		sync_flop1 <= ASYNC;
        sync_flop2 <= sync_flop1;
	end
end


assign SYNC = sync_flop2;

endmodule
