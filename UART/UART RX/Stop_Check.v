module Stop_Check (
	input wire clk,
	input wire rst,
	input wire stop_chk_en,
	input wire sampled_bit,
	output reg stop_err
);

always @(posedge clk or negedge rst) begin
	if(~rst) begin
		stop_err <= 1'b0;
	end
	else if(stop_chk_en) begin
		stop_err <= ~sampled_bit;

		/*if(sampled_bit) begin
			stop_err <= 1'b0;
		end 
		else begin
			stop_err <= 1'b1;
		end*/
	end
end

endmodule
