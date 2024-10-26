module MUX (
	input wire CLK,
	input wire RST,
	input wire [1:0] MUX_Sel,
	input wire Start_Bit,
	input wire Ser_Data,
	input wire Par_Bit,
	input wire Stop_Bit,
	output reg TX_OUT
);

always @(posedge CLK or negedge RST) begin
	if (~RST) begin
		TX_OUT <= 1'b0;
	end
	else begin
		case (MUX_Sel)
			2'b00 : TX_OUT <= Start_Bit;
			2'b01 : TX_OUT <= Ser_Data;
			2'b11 : TX_OUT <= Par_Bit;
			2'b10 : TX_OUT <= Stop_Bit;
		endcase
	end
end

endmodule
