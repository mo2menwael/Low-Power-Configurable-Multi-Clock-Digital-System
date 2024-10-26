module UART_TX # (parameter Data_Width = 8)
(
	input wire clk,
	input wire rst,
	input wire [Data_Width-1:0] p_data,
	input wire data_valid,
	input wire par_en,
	input wire par_typ,
	output wire tx_out,
	output wire busy
);

// Internal connections
wire ser_done,ser_en,ser_data,par_bit;
wire [1:0] mux_sel;


Serializer U_Serializer (
.CLK       (clk),
.RST       (rst),
.Busy      (busy),
.P_DATA    (p_data),
.Data_Valid(data_valid),
.Ser_En    (ser_en),
.Ser_Data  (ser_data),
.Ser_Done  (ser_done)
);

TX_FSM U_FSM (
.CLK       (clk),
.RST       (rst),
.Ser_En    (ser_en),
.Ser_Done  (ser_done),
.Data_Valid(data_valid),
.PAR_EN    (par_en),
.MUX_Sel   (mux_sel),
.Busy      (busy)
);

Parity_Calc U_Parity_Calc (
.CLK       (clk),
.RST       (rst),
.Data_Valid(data_valid),
.Busy      (busy),
.P_DATA    (p_data),
.PAR_TYP   (par_typ),
.Par_Bit   (par_bit)
);

MUX U_MUX (
.CLK      (clk),
.RST      (rst),
.MUX_Sel  (mux_sel),
.Par_Bit  (par_bit),
.Ser_Data (ser_data),
.Start_Bit(1'b0),
.Stop_Bit (1'b1),
.TX_OUT   (tx_out)
);

endmodule
