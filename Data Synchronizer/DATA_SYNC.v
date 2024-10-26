module DATA_SYNC #(parameter BUS_WIDTH = 8, NUM_STAGES = 2) (
	input wire 				   CLK,
	input wire 				   RST,
	input wire 				   Bus_Enable,
	input wire [BUS_WIDTH-1:0] Unsync_Bus,
	output reg [BUS_WIDTH-1:0] Sync_Bus,
	output reg 				   Enable_Pulse
);

reg [NUM_STAGES-1:0] MultiFF;
wire Pulse_Gen;
reg enable_ff1; // Flip-flop for enable pulse generation

integer i;

always @(posedge CLK or negedge RST) begin
	if(~RST) begin
		MultiFF <= 'b0;
	end
	else begin
		MultiFF <= {MultiFF[NUM_STAGES-2:0],Bus_Enable};
	end
end

always @(posedge CLK or negedge RST) begin
	if(~RST) begin
		Sync_Bus <= 'b0;
	end
	else begin
		if (Pulse_Gen) begin
			for (i = 0; i < BUS_WIDTH; i = i + 1) begin
				Sync_Bus[i] <= Unsync_Bus[i];
			end
		end
	end
end


always @(posedge CLK or negedge RST) begin
	if(~RST) begin
		enable_ff1 <= 1'b0;
		Enable_Pulse <= 1'b0;
	end
	else begin
		enable_ff1 <= MultiFF[NUM_STAGES-1];
		Enable_Pulse <= Pulse_Gen;
	end
end

assign Pulse_Gen = (~enable_ff1) & (MultiFF[NUM_STAGES-1]);

endmodule
