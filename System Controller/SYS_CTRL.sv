module SYS_CTRL #(parameter Output_Width = 16, Register_Width = 8, Address_Width = 4) (
	input  wire 					 CLK,
	input  wire 					 RST,
	input  wire						 FIFO_FULL,
	input  wire [Output_Width-1:0]   ALU_OUT,
	input  wire 					 ALU_OUT_Valid,
	output  reg [3:0] 			     ALU_FUN,
	output  reg 					 ALU_EN,
	output  reg 					 CLK_Gate_EN,
	output  reg [Address_Width-1:0]  Address,
	output  reg 					 WrEn,
	output  reg 					 RdEn,
	output  reg [Register_Width-1:0] WrData,
	input  wire [Register_Width-1:0] RdData,
	input  wire 					 RdData_Valid,
	input  wire [Register_Width-1:0] RX_P_DATA,
	input  wire 					 RX_D_VLD,
	output  reg [Register_Width-1:0] TX_P_DATA,		// Data Sent to ASYNC FIFO
	output  reg 					 TX_D_VLD		// To act as Write_INC in ASYNC FIFO
);

typedef enum bit [3:0] {
		IDLE   	     	= 4'b0000,
		WRITE_ADDR	 	= 4'b0001,
		WRITE_DATA		= 4'b0011,
		READ_ADDR		= 4'b0010,
		READ_DATA	 	= 4'b0110,
		OPERAND_A	 	= 4'b0111,
		OPERAND_B	 	= 4'b0101,
		FUNCTION_ALU	= 4'b0100,
		SEND_ALU_OUT_F1 = 4'b1100,
		SEND_ALU_OUT_F2 = 4'b1101
} state;

state current_state, next_state;

always @(posedge CLK or negedge RST) begin
	if(~RST) begin
		current_state <= IDLE;
	end 
	else begin
		current_state <= next_state;
	end
end


reg [Address_Width-1:0] RegFile_Address;

always @(posedge CLK or negedge RST) begin
	if (~RST) begin
		RegFile_Address <= 'b0;
	end
	else if ((current_state == WRITE_ADDR || READ_ADDR) && RX_D_VLD) begin
		RegFile_Address <= RX_P_DATA;
	end
end

reg [Address_Width-1:0] Hold_Func_ALU;

always @(posedge CLK or negedge RST) begin
	if (~RST) begin
		Hold_Func_ALU <= 'b0;
	end
	else if ((current_state == FUNCTION_ALU) && RX_D_VLD) begin
		Hold_Func_ALU <= RX_P_DATA;
	end
end


always @(*) begin
	ALU_FUN 	= 'b0;
	WrData 		= 'b0;
	TX_P_DATA	= 'b0;
	Address 	= 'b0;
	ALU_EN 		= 1'b0;
	CLK_Gate_EN = 1'b0;
	WrEn 		= 1'b0;
	RdEn 		= 1'b0;
	TX_D_VLD	= 1'b0;

	case (current_state)
		IDLE		: begin
						if (RX_D_VLD) begin
							if (RX_P_DATA == 'hAA) begin
								next_state = WRITE_ADDR;
							end
							else if (RX_P_DATA == 'hBB) begin
								next_state = READ_ADDR;
							end
							else if (RX_P_DATA == 'hCC) begin
								next_state = OPERAND_A;
							end
							else if (RX_P_DATA == 'hDD) begin
								next_state = FUNCTION_ALU;
							end
							else begin
								next_state = IDLE;
							end
						end
						else begin
							next_state = IDLE;
						end
				  	  end

		WRITE_ADDR 	: begin
						if (RX_D_VLD) begin
							next_state = WRITE_DATA;
						end
						else begin
							next_state = WRITE_ADDR;
						end
				  	  end

		WRITE_DATA 	: begin
						if (RX_D_VLD) begin
							next_state = IDLE;
							Address = RegFile_Address;
							WrData = RX_P_DATA;
							WrEn = 1'b1;
						end
						else begin
							next_state = WRITE_DATA;
						end
				  	  end

		READ_ADDR 	: begin
						if (RX_D_VLD) begin
							next_state = READ_DATA;
						end
						else begin
							next_state = READ_ADDR;
						end
				  	  end

		READ_DATA 	: begin
						RdEn = 1'b1;
						Address = RegFile_Address;
						if (RdData_Valid && ~FIFO_FULL) begin
							next_state = IDLE;
							TX_P_DATA = RdData;
							TX_D_VLD = RdData_Valid;
						end
						else begin
							next_state = READ_DATA;
						end
				  	  end

		OPERAND_A 	: begin
						if (RX_D_VLD) begin
							Address = 'h0;
							WrData = RX_P_DATA;
							WrEn = 1'b1;
							next_state = OPERAND_B;
						end
						else begin
							next_state = OPERAND_A;
						end
				  	  end

		OPERAND_B 	: begin
						if (RX_D_VLD) begin
							Address = 'h1;
							WrData = RX_P_DATA;
							WrEn = 1'b1;
							next_state = FUNCTION_ALU;
						end
						else begin
							next_state = OPERAND_B;
						end
				  	  end		  	  		  	  

		FUNCTION_ALU: begin
						CLK_Gate_EN = 1'b1;
						if (RX_D_VLD) begin
							ALU_FUN = RX_P_DATA;
							ALU_EN 	= 1'b1;
							next_state = SEND_ALU_OUT_F1;
						end
						else begin
							next_state = FUNCTION_ALU;
						end
				  	  end

	    SEND_ALU_OUT_F1: begin
	    					ALU_EN 		= 1'b1;
							CLK_Gate_EN = 1'b1;
							ALU_FUN = Hold_Func_ALU;
							if (ALU_OUT_Valid && ~FIFO_FULL) begin
								TX_P_DATA = ALU_OUT[7:0];
								TX_D_VLD = ALU_OUT_Valid;
								next_state = SEND_ALU_OUT_F2;
						 	end
						 	else begin
								next_state = SEND_ALU_OUT_F1;
							end
				  	  	 end

		SEND_ALU_OUT_F2: begin
							ALU_EN 		= 1'b1;
							CLK_Gate_EN = 1'b1;
							ALU_FUN = Hold_Func_ALU;
							TX_P_DATA = ALU_OUT[15:8];
							TX_D_VLD = ALU_OUT_Valid;
							next_state = IDLE;
				  	  	 end

		default 	: begin
						next_state = IDLE;
					  end 
	endcase
end


endmodule