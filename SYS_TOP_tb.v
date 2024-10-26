`timescale 1ns/1ps
module SYS_TOP_tb # (parameter RST_SYNC_STAGES_tb = 2, DATA_WIDTH_tb = 8, Output_Width_tb = 2*DATA_WIDTH_tb , DATA_SYNC_STAGES_tb = 2,
						Div_Ratio_Width_tb = 8, FIFO_ADDRESS_WIDTH_tb = $clog2(MEMORY_DEPTH_tb), MEMORY_DEPTH_tb = 8,
						POINTER_WIDTH_tb = FIFO_ADDRESS_WIDTH_tb + 1, REG_FILE_ADDRESS_WIDTH_tb = 4, REG_FILE_DEPTH_tb = 16);

////////////////////////////////////////////////////////
///////////////////// Parameters ///////////////////////
////////////////////////////////////////////////////////

parameter REF_clock_period  = 10;
parameter UART_clock_period = 271.267;	// prescale (default) = 32
real TX_clock_period		= 8680.56;	// UART frequecny / 32 or UART_clock_period * 32 as divide raito (default) = 32

localparam [1:0] READ_FROM_REG = 2'd0, ALU_OPERAND = 2'd1, ALU_NO_OPERAND = 2'd2, RX_CONFIG_CHANGE = 2'd3;

integer failed;
integer successeded;
integer test_case_num;

////////////////////////////////////////////////////////
/////////////////////// Signals ////////////////////////
////////////////////////////////////////////////////////

reg RST_N_tb;
reg UART_CLK_tb;
reg REF_CLK_tb;
reg UART_RX_IN_tb;
wire UART_TX_O_tb;
wire parity_error_tb;
wire framing_error_tb;

reg [DATA_WIDTH_tb+2:0] Frame_1;
reg [DATA_WIDTH_tb+2:0] Frame_2;
integer i;

////////////////////////////////////////////////////////
////////////////// Initial Block ///////////////////////
////////////////////////////////////////////////////////

initial
 begin
 	$dumpfile("SYS_TOP.vcd");
	$dumpvars;

	initialize();

	reset();

	// Note: Default is Even Parity

	////////////////////// Reg File Write Tests /////////////////////

	RegFile_Write('b0_1010_1010_0_1,'b0_0000_0100_1_1,'b0_1010_1110_1_1);	// 0xAA - 0x4 - 0xAE

	RegFile_Write('b0_1010_1010_0_1,'b0_0000_1010_0_1,'b0_0000_0011_0_1);	// 0xAA - 0xA - 0x03

	RegFile_Write('b0_1010_1010_0_1,'b0_0000_1000_1_1,'b0_1111_1111_0_1);	// 0xAA - 0x8 - 0xFF

	RegFile_Write('b0_1010_1010_0_1,'b0_0000_1111_0_1,'b0_0110_0101_0_1);	// 0xAA - 0xF - 0x65

	///////////////////// Reg File Read Tests ///////////////////////

	RegFile_Read('b0_1011_1011_0_1,'b0_0000_0100_1_1);						// 0xBB - 0x4

	RegFile_Read('b0_1011_1011_0_1,'b0_0000_1010_0_1);						// 0xBB - 0xA

	RegFile_Read('b0_1011_1011_0_1,'b0_0000_1000_1_1);						// 0xBB - 0x8

	RegFile_Read('b0_1011_1011_0_1,'b0_0000_1111_0_1);						// 0xBB - 0xF

	/////////////////// ALU With Operands Tests /////////////////////

	ALU_With_Operands('b0_1100_1100_0_1,'b0_0000_1000_1_1,'b0_0000_0110_0_1,'b0_0000_0001_1_1); 	// 0xCC - 0x8  - 0x6 - 0b0001(subtraction)

	ALU_With_Operands('b0_1100_1100_0_1,'b0_0001_0100_0_1,'b0_0000_1010_0_1,'b0_0000_0010_1_1); 	// 0xCC - 0d20 - 0xA - 0b0010(multiplication)

	ALU_With_Operands('b0_1100_1100_0_1,'b0_1110_1010_1_1,'b0_0000_1011_1_1,'b0_0000_0111_1_1); 	// 0xCC - 0xEA - 0xB - 0b0111(NOR)

	ALU_With_Operands('b0_1100_1100_0_1,'b0_0011_0010_1_1,'b0_0011_0010_1_1,'b0_0000_1010_0_1); 	// 0xCC - 0d50 - 0d50 - 0x1010(Is Equal ?)

	///////////////// ALU Without Operands Tests ////////////////////

	ALU_WithOut_Operands('b0_1101_1101_0_1,'b0_0000_1100_0_1); 				// 0xDD - 0b1100 (Is A<B ?)

	ALU_WithOut_Operands('b0_1101_1101_0_1,'b0_0000_1110_1_1); 				// 0xDD - 0b1110 (shift left A -> A*2)

	ALU_WithOut_Operands('b0_1101_1101_0_1,'b0_0000_0010_1_1); 				// 0xDD - 0b0010 (multiplication)

	ALU_WithOut_Operands('b0_1101_1101_0_1,'b0_0000_0011_0_1); 				// 0xDD - 0b0011 (division)

	//xxxxxxxxxxxxxxxxxxxxxxx Wrong Tests xxxxxxxxxxxxxxxxxxxxxxxxx//

	RegFile_Read('b0_1011_1011_1_1,'b0_0000_1010_1_1);						// Wrong Parity Bit

	ALU_WithOut_Operands('b0_1101_1101_0_1,'b0_0000_1100_0_0); 				// Wrong Stop Bit


	#(50*TX_clock_period);
	$stop;
 end

initial
 begin
 	/////////////////////////// Check Reg File Read Tests ////////////////////////////

 	Check_Output('b0_1010_1110_1_1, READ_FROM_REG);

 	Check_Output('b0_0000_0011_0_1, READ_FROM_REG);

 	Check_Output('b0_1111_1111_0_1, READ_FROM_REG);

 	Check_Output('b0_0110_0101_0_1, READ_FROM_REG);

 	// Note: In ALU checks we sent 2 frames
 	///////////////////// Check ALU With Operands Output Tests ///////////////////////

 	Check_Output('b0_0000_0000_0_1_0_0000_0010_1_1, ALU_OPERAND);

 	Check_Output('b0_0000_0000_0_1_0_1100_1000_1_1, ALU_OPERAND);

 	Check_Output('b0_1111_1111_0_1_0_0001_0100_0_1, ALU_OPERAND);

 	Check_Output('b0_0000_0000_0_1_0_0000_0001_1_1, ALU_OPERAND);

 	/////////////////// Check ALU Without Operands Output Tests //////////////////////

 	Check_Output('b0_0000_0000_0_1_0_0000_0000_0_1, ALU_NO_OPERAND);

 	Check_Output('b0_0000_0000_0_1_0_0110_0100_1_1, ALU_NO_OPERAND);

 	Check_Output('b0_0000_1001_0_1_0_1100_0100_1_1, ALU_NO_OPERAND);

 	Check_Output('b0_0000_0000_0_1_0_0000_0001_1_1, ALU_NO_OPERAND);

 	//xxxxxxxxxxxxxxxxxxxxxxxxxxxxx Check Wrong Test xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//

 	Check_Wrong_ParityBit();

 	Check_Wrong_StopBit();


 	$display("\nNumber of Failed Test cases    : %0d", failed);
	$display("Number of Successed Test cases : %0d", successeded);
 end


////////////////////////////////////////////////////////
/////////////////////// TASKS //////////////////////////
////////////////////////////////////////////////////////

/////////////// Signals Initialization /////////////////

task initialize;
 begin
 	failed = 0;
 	successeded = 0;
 	test_case_num = 0;
 	Frame_1 = 0;
 	Frame_2 = 0;
	UART_CLK_tb = 1'b0;
	REF_CLK_tb  = 1'b0;
	UART_RX_IN_tb = 1'b1;
 end
endtask

////////////////////// RESET //////////////////////////

task reset;
 begin
 	RST_N_tb = 1'b0;
 	#TX_clock_period
 	RST_N_tb = 1'b1;
 end
endtask

/////////////////// RegFile_Write ////////////////////

task RegFile_Write;
 input [DATA_WIDTH_tb+2:0] Command, Address, Data;

 begin
 	Send_Data(Command);
 	Send_Data(Address);
 	Send_Data(Data);
 end
endtask

/////////////////// Send_Data ////////////////////

task Send_Data;
 input [DATA_WIDTH_tb+2:0] Input_Data;

 integer m;

 begin
 	UART_RX_IN_tb = Input_Data[DATA_WIDTH_tb + 2];			// Start Bit
 	#(TX_clock_period);

 	for (m = 2; m <= DATA_WIDTH_tb + 1; m = m + 1) begin    // Data Bits
 		UART_RX_IN_tb = Input_Data[m];
 		#(TX_clock_period);
 	end

 	UART_RX_IN_tb = Input_Data[1];							// Parity Bit
 	#(TX_clock_period);

 	UART_RX_IN_tb = Input_Data[0];							// Stop Bit
 	#(TX_clock_period);
 end
endtask

/////////////////// RegFile_Read ////////////////////

task RegFile_Read;
 input [DATA_WIDTH_tb+2:0] Command, Address;

 begin
 	Send_Data(Command);
 	Send_Data(Address);
 	#(TX_clock_period);
 end
endtask

/////////////////// ALU_With_Operands //////////////////

task ALU_With_Operands;
 input [DATA_WIDTH_tb+2:0] Command, Op1, Op2, Func;

 begin
 	Send_Data(Command);
 	Send_Data(Op1);
 	Send_Data(Op2);
 	Send_Data(Func);
 	#(TX_clock_period);
 end
endtask

////////////////// ALU_WithOut_Operands ////////////////

task ALU_WithOut_Operands;
 input [DATA_WIDTH_tb+2:0] Command, Func;

 begin
 	Send_Data(Command);
 	Send_Data(Func);
 	#(TX_clock_period);
 end
endtask

//////////////////// Check_Output //////////////////////

task Check_Output;
 input [(DATA_WIDTH_tb+2)*2:0] Expected_Output;
 input [1:0] mode;

 integer k;

 begin
 	Frame_1 = 0;
 	test_case_num = test_case_num + 1;
 	@(posedge U_SYS_TOP.U_UART_TX.busy);

 	// Start Bit
 	#(TX_clock_period);
 	Frame_1[10] = UART_TX_O_tb;

	// Data Bits
 	for (i = 2; i < 10; i = i + 1) begin
 		#(TX_clock_period)
 		Frame_1[i] = UART_TX_O_tb;
 	end

 	// Parity Bit
 	#(TX_clock_period);
 	Frame_1[1] = UART_TX_O_tb;

 	// Stop Bit
 	#(TX_clock_period);
 	Frame_1[0] = UART_TX_O_tb;

 	if (mode == READ_FROM_REG) begin
 		if (Frame_1 == Expected_Output) begin
 			$display("Test case %0d successeded -> DATA READ FROM REG = %8b", test_case_num, Frame_1[9:2]);
 			successeded = successeded + 1;
 		end
 		else begin
 			$display("Test case %0d failed -> DATA READ FROM REG = %8b", test_case_num, Frame_1[9:2]);
 			failed = failed + 1;
 		end
 	end
 	else begin
 		Frame_2 = 0;
 		@(posedge U_SYS_TOP.U_UART_TX.busy);

 		// Start Bit
 		#(TX_clock_period);
 		Frame_2[10] = UART_TX_O_tb;

		// Data Bits
 		for (k = 2; k < 10; k = k + 1) begin
 			#(TX_clock_period)
 			Frame_2[k] = UART_TX_O_tb;
 		end

 		// Parity Bit
	 	#(TX_clock_period);
	 	Frame_2[1] = UART_TX_O_tb;

	 	// Stop Bit
	 	#(TX_clock_period);
	 	Frame_2[0] = UART_TX_O_tb;

	 	if ({Frame_2, Frame_1} == Expected_Output) begin
 			$display("Test case %0d successeded -> ALU OUTPUT = %16b", test_case_num, {Frame_2[9:2], Frame_1[9:2]});
 			successeded = successeded + 1;
 		end
 		else begin
 			$display("Test case %0d failed -> ALU OUTPUT = %16b", test_case_num, {Frame_2[9:2], Frame_1[9:2]});
 			failed = failed + 1;
 		end
 	end
 end
endtask

///////////////// Check_Wrong_ParityBit ////////////////

task Check_Wrong_ParityBit;
 begin
 	test_case_num = test_case_num + 1;

 	if (parity_error_tb) begin
 		$display("Test case %0d successeded -> Parity Error = %1b", test_case_num, parity_error_tb);
 		successeded = successeded + 1;
 	end
 	else begin
 		$display("Test case %0d failed -> Parity Error = %1b", test_case_num, parity_error_tb);
 		failed = failed + 1;
 	end
 end
endtask

///////////////// Check_Wrong_StopBit //////////////////

task Check_Wrong_StopBit;
 begin
 	test_case_num = test_case_num + 1;
 
 	@(posedge framing_error_tb);
 	if (framing_error_tb) begin
 		$display("Test case %0d successeded -> Framing Error = %1b", test_case_num, framing_error_tb);
 		successeded = successeded + 1;
 	end
 	else begin
 		$display("Test case %0d failed -> Framing Error = %1b", test_case_num, framing_error_tb);
 		failed = failed + 1;
 	end
 end
endtask

////////////////////////////////////////////////////////
/////////////////// Clock Generation ///////////////////
////////////////////////////////////////////////////////

always #(REF_clock_period/2)  REF_CLK_tb  = ~REF_CLK_tb;

always #(UART_clock_period/2) UART_CLK_tb = ~UART_CLK_tb;

////////////////////////////////////////////////////////
/////////////////// DUT Instantation ///////////////////
////////////////////////////////////////////////////////

SYS_TOP #(.DATA_WIDTH(DATA_WIDTH_tb), .RST_SYNC_STAGES(RST_SYNC_STAGES_tb), .Output_Width(Output_Width_tb), .MEMORY_DEPTH(MEMORY_DEPTH_tb),
			.FIFO_ADDRESS_WIDTH(FIFO_ADDRESS_WIDTH_tb), .DATA_SYNC_STAGES(DATA_SYNC_STAGES_tb), .Div_Ratio_Width(Div_Ratio_Width_tb),
			.POINTER_WIDTH(POINTER_WIDTH_tb), .REG_FILE_ADDRESS_WIDTH(REG_FILE_ADDRESS_WIDTH_tb), .REG_FILE_DEPTH(REG_FILE_DEPTH_tb)) U_SYS_TOP (
.RST_N        (RST_N_tb),
.UART_CLK     (UART_CLK_tb),
.REF_CLK      (REF_CLK_tb),
.UART_RX_IN   (UART_RX_IN_tb),
.UART_TX_O    (UART_TX_O_tb),
.parity_error (parity_error_tb),
.framing_error(framing_error_tb)
);

endmodule
