module Deserializer # (parameter Data_Width = 8)
(
	input wire clk,
	input wire rst,
	input wire deser_en,
	input wire sampled_bit,
	output reg [Data_Width-1:0] p_data	
);

always @(posedge clk or negedge rst) begin
	if (~rst) begin
		p_data <= 'b0;
	end
	else if (deser_en) begin
        p_data <= {sampled_bit, p_data[Data_Width-1:1]};
    end
end

endmodule

