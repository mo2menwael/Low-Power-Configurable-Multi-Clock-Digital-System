module Par_Check # (parameter Data_Width = 8)
(
	input wire clk,
	input wire rst,
	input wire par_typ,
	input wire par_chk_en,
	input wire sampled_bit,
	input wire [Data_Width-1:0] p_data,
	output reg par_err
);

reg parity_bit;

always @(*) begin
	if (par_typ) begin
		parity_bit = ~^p_data;	// Odd parity
	end
	else begin
		parity_bit = ^p_data;	// Even parity
	end
end

always @(posedge clk or negedge rst) begin
	if(~rst) begin
		par_err <= 1'b0;
	end
	else if(par_chk_en) begin
		par_err <= ~(sampled_bit == parity_bit);
		
		/*if(sampled_bit == parity_bit) begin
			par_err <= 1'b0;
		end 
		else begin
			par_err <= 1'b1;
		end*/
	end
end



endmodule
