module CLK_GATE (
	input wire  CLK,
	input wire  CLK_EN,
	output wire GATED_CLK
);

reg Latch_Output;

always @(CLK_EN or CLK) begin
	if (~CLK) begin
		Latch_Output <= CLK_EN;
	end
end

assign GATED_CLK = Latch_Output & CLK;

/*TLATNCAX4M  U0_TLATNCAX4M (
.E(CLK_EN),
.CK(CLK),
.ECK(GATED_CLK)
);*/

endmodule
