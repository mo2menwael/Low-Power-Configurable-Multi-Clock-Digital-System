module Serializer # (parameter Data_Width = 8)
(
	input wire CLK,
	input wire RST,
	input wire [Data_Width-1:0] P_DATA,
	input wire Data_Valid,
	input wire Ser_En,
	input wire Busy,
	output wire Ser_Data,
	output reg Ser_Done
);

reg [Data_Width-1:0] Registered_Data;	// Register to hold data
reg [2:0] counter;

always @(posedge CLK or negedge RST) begin
	if (~RST) begin
		Ser_Done <= 1'b0;
		Registered_Data <= 'b0;
		counter <= 'b0;
	end
	else if (Data_Valid && ~Busy) begin
		Ser_Done <= 1'b0;
		Registered_Data <= P_DATA;
		counter <= 'b0;
	end
	else if (Ser_En && ~Ser_Done) begin
		Registered_Data <= Registered_Data >> 1;

		counter <= counter + 1;
		Ser_Done <= (counter == 3'b111);
	end
	else begin
		Ser_Done <= 1'b0;
		Registered_Data <= 'b0;
		counter <= 'b0;
	end
end

assign Ser_Data = Registered_Data[0];

endmodule
