module SYS_TOP #(parameter RST_SYNC_STAGES = 2, DATA_WIDTH = 8, Output_Width = 2*DATA_WIDTH , DATA_SYNC_STAGES = 2, Div_Ratio_Width = 8,
					FIFO_ADDRESS_WIDTH = 3, MEMORY_DEPTH = 8, POINTER_WIDTH = FIFO_ADDRESS_WIDTH + 1,REG_FILE_ADDRESS_WIDTH = 4,
					REG_FILE_DEPTH = 16)
(
 input  wire RST_N,
 input  wire UART_CLK,
 input  wire REF_CLK,
 input  wire UART_RX_IN,
 input wire SI,
 input wire SE,
 input wire test_mode,
 input wire scan_clk,
 input wire scan_rst,
 output wire SO,
 output wire UART_TX_O,
 output wire parity_error,
 output wire framing_error
);

//******************** Internal Signal Declaration ********************//

/********* UART RX OUTPUT SIGNALS **********/
wire [DATA_WIDTH-1:0] RX_Out_UnSync;
wire 				  RX_Valid_UnSync;

/******** DATA SYNC OUTPUT SIGNALS ********/
wire [DATA_WIDTH-1:0] RX_Out_Sync;
wire				  RX_Valid_Sync;

/******** SYS CTRL OUTPUT SIGNALS *********/
wire 							  ALU_EN;
wire [3:0] 						  ALU_FUN;
wire 							  CLK_Gate_EN;
wire 							  WrEn;
wire 							  RdEn;
wire [REG_FILE_ADDRESS_WIDTH-1:0] Reg_file_Address;
wire [DATA_WIDTH-1:0] 			  Reg_WrData;
wire [DATA_WIDTH-1:0] 			  FIFO_WR_DATA;		// Sent to fifo then uart tx
wire 							  WR_INC;			// Sent to fifo then uart tx
wire [Div_Ratio_Width-1:0] 		  RX_DIV_RATIO;

/*********** ALU OUTPUT SIGNALS ***********/
wire [Output_Width-1:0] ALU_OUT;
wire 					ALU_OUT_Valid;

/********* RegFile OUTPUT SIGNALS *********/
wire [DATA_WIDTH-1:0] Reg_RdData;
wire 				  RdData_Valid;
wire [DATA_WIDTH-1:0] REG0;
wire [DATA_WIDTH-1:0] REG1;
wire [DATA_WIDTH-1:0] REG2;
wire [DATA_WIDTH-1:0] REG3;

/******** ASYNC FIFO OUTPUT SIGNALS *******/
wire 				  FULL;
wire 				  EMPTY;
wire [DATA_WIDTH-1:0] FIFO_RD_DATA;

/********** UART TX OUTPUT SIGNALS ********/
wire Busy;

/********* Pulse Gen OUTPUT SIGNALS *******/
wire RD_INC;

/********* Clock Gate OUTPUT SIGNALS ********/
wire ALU_CLK;

/********* Clock Divider OUTPUT SIGNALS *********/
wire TX_CLK;
wire RX_CLK;

/******** RST SYNC OUTPUT SIGNALS *********/
wire SYNC_RST_REF;
wire SYNC_RST_UART;

/************** DFT SIGNALS **************/
wire REF_CLK_DFT, UART_CLK_DFT, TX_CLK_DFT, RX_CLK_DFT, ALU_CLK_DFT;
wire RST_N_DFT, SYNC_RST_UART_DFT, SYNC_RST_REF_DFT;

///********************************************************///
/////////////////////////// DFT MUXs /////////////////////////
///********************************************************///

// Muxing clock
mux2X1 U0_mux2X1 (
.IN_0(REF_CLK),
.IN_1(scan_clk),
.SEL(test_mode),
.OUT(REF_CLK_DFT)
);

mux2X1 U1_mux2X1 (
.IN_0(UART_CLK),
.IN_1(scan_clk),
.SEL(test_mode),
.OUT(UART_CLK_DFT)
);

mux2X1 U2_mux2X1 (
.IN_0(TX_CLK),
.IN_1(scan_clk),
.SEL(test_mode),
.OUT(TX_CLK_DFT)
);

mux2X1 U3_mux2X1 (
.IN_0(RX_CLK),
.IN_1(scan_clk),
.SEL(test_mode),
.OUT(RX_CLK_DFT)
);

// Muxing reset
mux2X1 U4_mux2X1 (
.IN_0(RST_N),
.IN_1(scan_rst),
.SEL(test_mode),
.OUT(RST_N_DFT)
);

mux2X1 U5_mux2X1 (
.IN_0(SYNC_RST_REF),
.IN_1(scan_rst),
.SEL(test_mode),
.OUT(SYNC_RST_REF_DFT)
);

mux2X1 U6_mux2X1 (
.IN_0(SYNC_RST_UART),
.IN_1(scan_rst),
.SEL(test_mode),
.OUT(SYNC_RST_UART_DFT)
);

///********************************************************///
//////////////////// Reset synchronizers /////////////////////
///********************************************************///

RST_SYNC #(.NUM_STAGES(RST_SYNC_STAGES)) RST_SYNC_1 (
.CLK     (REF_CLK_DFT),
.RST     (RST_N_DFT),
.SYNC_RST(SYNC_RST_REF)
);

RST_SYNC #(.NUM_STAGES(RST_SYNC_STAGES)) RST_SYNC_2 (
.CLK     (UART_CLK_DFT),
.RST     (RST_N_DFT),
.SYNC_RST(SYNC_RST_UART)
);

///********************************************************///
///////////////////// Data Synchronizers /////////////////////
///********************************************************///

DATA_SYNC #(.NUM_STAGES(DATA_SYNC_STAGES), .BUS_WIDTH(DATA_WIDTH)) U_DATA_SYNC (
.CLK         (REF_CLK_DFT),
.RST         (SYNC_RST_REF_DFT),
.Unsync_Bus  (RX_Out_UnSync),
.Sync_Bus    (RX_Out_Sync),
.Bus_Enable  (RX_Valid_UnSync),
.Enable_Pulse(RX_Valid_Sync)
);

///********************************************************///
/////////////////////// Async FIFO ///////////////////////////
///********************************************************///

ASYNC_FIFO #(.DATA_WIDTH(DATA_WIDTH), .ADDRESS_WIDTH(FIFO_ADDRESS_WIDTH), .BUS_WIDTH(POINTER_WIDTH), .ADDRESS_DEPTH(MEMORY_DEPTH)) U_ASYNC_FIFO (
.W_CLK  (REF_CLK_DFT),
.W_RST  (SYNC_RST_REF_DFT),
.W_INC  (WR_INC),
.R_CLK  (TX_CLK_DFT),
.R_RST  (SYNC_RST_UART_DFT),
.R_INC  (RD_INC),
.WR_DATA(FIFO_WR_DATA),
.RD_DATA(FIFO_RD_DATA),
.FULL   (FULL),
.EMPTY  (EMPTY)
);

///********************************************************///
////////////////////// Pulse Generator ///////////////////////
///********************************************************///

PULSE_GEN U_PULSE_GEN (
.CLK      (TX_CLK_DFT),
.RST      (SYNC_RST_UART_DFT),
.LVL_SIG  (Busy),
.PULSE_SIG(RD_INC)
);

///********************************************************///
////////////// Clock Divider for UART_TX Clock ///////////////
///********************************************************///

CLK_DIV #(.Div_Ratio_Width(Div_Ratio_Width)) U_CLK_DIV_TX (
.i_ref_clk  (UART_CLK_DFT),
.i_rst_n    (SYNC_RST_UART_DFT),
.i_clk_en   (1'b1),
.i_div_ratio(REG3),
.o_div_clk  (TX_CLK)
);

///********************************************************///
/////////////////////// Custom Mux Clock /////////////////////
///********************************************************///

CLKDIV_MUX U_CLKDIV_MUX (
.PreScale (REG2[7:2]),
.Div_Ratio(RX_DIV_RATIO)
);

///********************************************************///
////////////// Clock Divider for UART_RX Clock ///////////////
///********************************************************///

CLK_DIV #(.Div_Ratio_Width(Div_Ratio_Width)) U_CLK_DIV_RX (
.i_ref_clk  (UART_CLK_DFT),
.i_rst_n    (SYNC_RST_UART_DFT),
.i_clk_en   (1'b1),
.i_div_ratio(RX_DIV_RATIO),
.o_div_clk  (RX_CLK)
);

///********************************************************///
/////////////////////////// UART /////////////////////////////
///********************************************************///

UART_TX #(.Data_Width(DATA_WIDTH)) U_UART_TX (
.clk       (TX_CLK_DFT),
.rst       (SYNC_RST_UART_DFT),
.p_data    (FIFO_RD_DATA),
.data_valid(~EMPTY),
.par_en    (REG2[0]),
.par_typ   (REG2[1]),
.tx_out    (UART_TX_O),
.busy      (Busy)
);

UART_RX #(.Data_Width(DATA_WIDTH)) U_UART_RX (
.CLK         (RX_CLK_DFT),
.RST         (SYNC_RST_UART_DFT),
.PRESCALAR   (REG2[7:2]),
.PAR_EN      (REG2[0]),
.PAR_TYP     (REG2[1]),
.RX_IN       (UART_RX_IN),
.P_DATA      (RX_Out_UnSync),
.Data_Valid  (RX_Valid_UnSync),
.Parity_Error(parity_error),
.Stop_Error  (framing_error)
);

///********************************************************///
////////////////////// Register File /////////////////////////
///********************************************************///

REG_FILE #(.Address_Width(REG_FILE_ADDRESS_WIDTH), .Register_Width(DATA_WIDTH), .Register_Depth(REG_FILE_DEPTH)) U_REG_FILE (
.CLK         (REF_CLK_DFT),
.RST         (SYNC_RST_REF_DFT),
.WrEn        (WrEn),
.RdEn        (RdEn),
.Address     (Reg_file_Address),
.WrData      (Reg_WrData),
.RdData      (Reg_RdData),
.RdData_Valid(RdData_Valid),
.REG0        (REG0),
.REG1        (REG1),
.REG2        (REG2),
.REG3        (REG3)
);

///********************************************************///
/////////////////////////// ALU //////////////////////////////
///********************************************************///

ALU #(.Operand_Width(DATA_WIDTH), .Output_Width(Output_Width)) U_ALU (
.CLK      (ALU_CLK),
.RST      (SYNC_RST_REF_DFT),
.EN       (ALU_EN),
.A        (REG0),
.B        (REG1),
.ALU_FUN  (ALU_FUN),
.ALU_OUT  (ALU_OUT),
.OUT_VALID(ALU_OUT_Valid)
);

///********************************************************///
///////////////////// System Controller //////////////////////
///********************************************************///

SYS_CTRL #(.Output_Width(Output_Width), .Register_Width(DATA_WIDTH), .Address_Width(REG_FILE_ADDRESS_WIDTH)) U_SYS_CTRL (
.CLK          (REF_CLK_DFT),
.RST          (SYNC_RST_REF_DFT),
.CLK_Gate_EN  (CLK_Gate_EN),
.FIFO_FULL    (FULL),
.ALU_FUN      (ALU_FUN),
.ALU_OUT      (ALU_OUT),
.ALU_OUT_Valid(ALU_OUT_Valid),
.ALU_EN       (ALU_EN),
.Address      (Reg_file_Address),
.RdEn         (RdEn),
.WrEn         (WrEn),
.RdData       (Reg_RdData),
.RdData_Valid (RdData_Valid),
.WrData       (Reg_WrData),
.RX_P_DATA    (RX_Out_Sync),
.RX_D_VLD     (RX_Valid_Sync),
.TX_P_DATA    (FIFO_WR_DATA),
.TX_D_VLD     (WR_INC)
);

///********************************************************///
/////////////////////// Clock Gating /////////////////////////
///********************************************************///

CLK_GATE U_CLK_GATE (
.CLK      (REF_CLK_DFT),
.CLK_EN   (CLK_Gate_EN|test_mode),
.GATED_CLK(ALU_CLK)
);


endmodule
 
