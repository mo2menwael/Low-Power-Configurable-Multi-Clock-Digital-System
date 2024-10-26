module UART_RX # (parameter Data_Width = 8)
(
	input wire CLK,
	input wire RST,
	input wire [5:0] PRESCALAR,
	input wire PAR_EN,
	input wire PAR_TYP,
	input wire RX_IN,
	output wire [Data_Width-1:0] P_DATA,
	output wire Parity_Error,
	output wire Stop_Error,
	output wire Data_Valid
);

// Internal Signals
wire deser_en, data_samp_en, edge_bit_cnt_en;
wire par_chk_en, stop_chk_en, start_chk_en;
wire sampled_bit;
wire [5:0] edge_cnt;
wire [3:0] bit_cnt;
wire start_glitch;

Deserializer U_Deserializer (
.deser_en   (deser_en),
.sampled_bit(sampled_bit),
.clk        (CLK),
.rst        (RST),
.p_data     (P_DATA)
);

Data_Sampling U_Data_Sampling (
.sampled_bit (sampled_bit),
.clk         (CLK),
.rst         (RST),
.edge_cnt    (edge_cnt),
.data_samp_en(data_samp_en),
.rx_in       (RX_IN),
.prescalar   (PRESCALAR)
);

Edge_Bit_Counter U_Edge_Bit_Counter (
.clk            (CLK),
.rst            (RST),
.edge_cnt       (edge_cnt),
.prescalar      (PRESCALAR),
.bit_cnt        (bit_cnt),
.edge_bit_cnt_en(edge_bit_cnt_en)
);

RX_FSM U_FSM (
.clk            (CLK),
.rst            (RST),
.edge_cnt       (edge_cnt),
.bit_cnt        (bit_cnt),
.deser_en       (deser_en),
.data_samp_en   (data_samp_en),
.edge_bit_cnt_en(edge_bit_cnt_en),
.rx_in          (RX_IN),
.prescalar      (PRESCALAR),
.par_chk_en     (par_chk_en),
.stop_chk_en    (stop_chk_en),
.start_chk_en   (start_chk_en),
.start_glitch   (start_glitch),
.par_en         (PAR_EN),
.par_err        (Parity_Error),
.stop_err       (Stop_Error),
.data_valid     (Data_Valid)
);

Par_Check U_Par_Check (
.clk        (CLK),
.rst        (RST),
.p_data     (P_DATA),
.sampled_bit(sampled_bit),
.par_chk_en (par_chk_en),
.par_err    (Parity_Error),
.par_typ    (PAR_TYP)
);

Start_Check U_Start_Check (
.clk         (CLK),
.rst         (RST),
.sampled_bit (sampled_bit),
.start_chk_en(start_chk_en),
.start_glitch(start_glitch)
);

Stop_Check U_Stop_Check (
.clk        (CLK),
.rst        (RST),
.sampled_bit(sampled_bit),
.stop_chk_en(stop_chk_en),
.stop_err   (Stop_Error)
);

endmodule
