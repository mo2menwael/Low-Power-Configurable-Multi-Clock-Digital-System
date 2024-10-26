module Parity_Calc # (parameter Data_Width = 8)
(
	input wire CLK,
	input wire RST,
	input wire [Data_Width-1:0] P_DATA,
	input wire Busy,
	input wire PAR_TYP,
	input wire Data_Valid,
	output reg Par_Bit
);

reg [Data_Width-1:0] Hold_data;				// Register to hold data

always @(posedge CLK or negedge RST) begin
	if (~RST) begin
		Par_Bit <= 1'b0;
		Hold_data <= 'b0;
	end
	else if (Data_Valid && ~Busy) begin
		Hold_data <= P_DATA;
	end
	else if (PAR_TYP) begin
		Par_Bit <= ~^Hold_data;				// Odd parity bit
	end
	else if (~PAR_TYP) begin
		Par_Bit <= ^Hold_data;				// Even parity bit
	end
end


endmodule
