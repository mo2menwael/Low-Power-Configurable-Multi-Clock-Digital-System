module FIFO_MEM_CNTRL # (parameter ADDRESS_WIDTH = 3, ADDRESS_DEPTH = 8, DATA_WIDTH = 8)
(
	input wire wclk,
	input wire wrst,
	input wire wclken,
	input wire [DATA_WIDTH-1:0] wdata,
	input wire [ADDRESS_WIDTH-1:0] waddr,
	input wire [ADDRESS_WIDTH-1:0] raddr,
	output wire [DATA_WIDTH-1:0] rdata
);

reg [DATA_WIDTH-1:0] memory [ADDRESS_DEPTH-1:0];

integer i;

always @(posedge wclk or negedge wrst) begin
	if (~wrst) begin
		for(i = 0; i < ADDRESS_DEPTH; i = i + 1) begin
            memory[i] <= 'b0;
        end
	end
	else if(wclken) begin
		memory[waddr] <= wdata;
	end
end

assign rdata = memory[raddr];

endmodule
