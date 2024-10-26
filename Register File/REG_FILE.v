module REG_FILE #(parameter Register_Depth = 16, Register_Width = 8, Address_Width = 4) (
	input wire 						 CLK,
	input wire 						 RST,
	input wire 						 WrEn,
	input wire 						 RdEn,
	input wire [Address_Width-1:0]   Address,
	input wire [Register_Width-1:0]  WrData,
	output reg [Register_Width-1:0]  RdData,
	output reg 						 RdData_Valid,
	output wire [Register_Width-1:0] REG0,
	output wire [Register_Width-1:0] REG1,
	output wire [Register_Width-1:0] REG2,
	output wire [Register_Width-1:0] REG3
);

reg [Register_Width-1:0] Register [Register_Depth-1:0];

integer i;

always @(posedge CLK or negedge RST)
 begin
	if(~RST) begin
		RdData <= 'b0;
		RdData_Valid <= 1'b0;

		for (i = 0; i < Register_Depth; i = i + 1) begin
			if (i == 2) begin
				Register[i] <= 'b100000_01;
			end
			else if (i == 3) begin
				Register[i] <= 'd32;
			end
			else begin
				Register[i] <= 'b0;
			end
		end
	end 
	else if(WrEn && ~RdEn) begin
		Register[Address] <= WrData;
	end
	else if (RdEn && ~WrEn) begin
		RdData <= Register[Address];
		RdData_Valid <= 1'b1;
	end
	else begin
		RdData_Valid <= 1'b0;
	end
 end

assign REG0 = Register[0];
assign REG1 = Register[1];
assign REG2 = Register[2];
assign REG3 = Register[3];

endmodule

