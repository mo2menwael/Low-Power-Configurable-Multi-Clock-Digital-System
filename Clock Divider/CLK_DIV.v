module CLK_DIV #(parameter Div_Ratio_Width = 8) (
	input wire 						 i_ref_clk,
	input wire 						 i_rst_n,
	input wire 						 i_clk_en,
	input wire [Div_Ratio_Width-1:0] i_div_ratio,
	output wire 					 o_div_clk
);

// Clock Divider block Enable while diving ration not equals to zero or one
wire ClK_DIV_EN;
assign ClK_DIV_EN = i_clk_en && (i_div_ratio != 'b0) && (i_div_ratio != 'b1);


// Odd divide ratio condition
wire Odd;
assign Odd = i_div_ratio[0];


// Half divide ratio calculation
wire [Div_Ratio_Width-2:0] half_div_ratio;
assign half_div_ratio = i_div_ratio >> 1;


// Half divide ratio plus 1 calculation
wire [Div_Ratio_Width-2:0] half_div_ratio_plus1;
assign half_div_ratio_plus1 = (i_div_ratio >> 1) + 1;


// Choose the output clock based on divide ratio
reg div_clk;
assign o_div_clk = ClK_DIV_EN ? div_clk : i_ref_clk;


// Signal to check output clock value
reg One_NotZero;

// Counter signal
reg [Div_Ratio_Width-2:0] counter;

always @(posedge i_ref_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		div_clk <= 1'b0;
		counter <= 'b1;
		One_NotZero <= 1'b0;
	end
	else if(ClK_DIV_EN) begin
		if (Odd) begin
			if (One_NotZero) begin
				counter <= counter + 1;
				if (counter == half_div_ratio) begin
					div_clk <= ~div_clk;
					counter <= 'b1;
					One_NotZero <= 1'b0;
				end
			end
			else begin
				counter <= counter + 1;
				if (counter == half_div_ratio_plus1) begin
					div_clk <= ~div_clk;
					counter <= 'b1;
					One_NotZero <= 1'b1;
				end
			end
		end
		else begin
			counter <= counter + 1;
			if (counter == half_div_ratio) begin
				div_clk <= ~div_clk;
				counter <= 'b1;
			end
		end
	end
end

endmodule
