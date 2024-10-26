module Edge_Bit_Counter (
	input wire clk,
	input wire rst,
	input wire edge_bit_cnt_en,
	input wire [5:0] prescalar,
	output reg [3:0] bit_cnt,
	output reg [5:0] edge_cnt
);

always @(posedge clk or negedge rst) begin
	if(~rst) begin
		bit_cnt <= 4'b0;
		edge_cnt <= 6'b1;
	end
	else if (edge_bit_cnt_en) begin
		if (edge_cnt == prescalar) begin
			edge_cnt <= 6'b1;  			// Reset edge counter after prescalar period
			bit_cnt <= bit_cnt + 1;
		end
		else begin
			edge_cnt <= edge_cnt + 1;
		end
	end
	else begin
		bit_cnt <= 4'b0;
		edge_cnt <= 6'b1;
	end
end

endmodule
