module Data_Sampling (
	input wire clk,
	input wire rst,
	input wire data_samp_en,
	input wire [5:0] edge_cnt,
	input wire rx_in,
	input wire [5:0] prescalar,
	output reg sampled_bit
);

wire [5:0] before_middle_sample, middle_sample, after_middle_sample;

assign middle_sample = (prescalar >> 1);
assign before_middle_sample = middle_sample - 1;
assign after_middle_sample  = middle_sample + 1;

reg sample1, sample2, sample3;

always @(posedge clk or negedge rst) begin
	if(~rst) begin
		sampled_bit <= 1'b0;
		sample1 <= 1'b0;
		sample2 <= 1'b0;
		sample3 <= 1'b0;
	end
	else if (data_samp_en) begin
		if (edge_cnt == before_middle_sample) begin
            sample1 <= rx_in;
        end
        else if (edge_cnt == middle_sample) begin
            sample2 <= rx_in;
       	end
       	else if (edge_cnt == after_middle_sample) begin
            sample3 <= rx_in;
        end
        else if (edge_cnt == after_middle_sample + 1) begin
        	sampled_bit <= (sample1 & sample2) | (sample2 & sample3) | (sample1 & sample3);
        end
	end
end

endmodule
