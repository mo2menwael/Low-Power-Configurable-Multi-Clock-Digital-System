module Start_Check (
	input wire clk,
	input wire rst,
	input wire start_chk_en,
	input wire sampled_bit,
	output reg start_glitch
);

always @(posedge clk or negedge rst) begin
	if(~rst) begin
		start_glitch <= 1'b0;
	end
	else if(start_chk_en) begin
		start_glitch <= sampled_bit;
		
		/*if(sampled_bit) begin
			start_glitch <= 1'b1;
		end 
		else begin
			start_glitch <= 1'b0;
		end*/
	end
end


endmodule
