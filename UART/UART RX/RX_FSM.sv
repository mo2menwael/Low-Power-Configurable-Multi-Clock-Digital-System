module RX_FSM (
	input wire clk,
	input wire rst,
	input wire rx_in,
	input wire par_en,
	input wire [3:0] bit_cnt,
	input wire [5:0] edge_cnt,
	input wire [5:0] prescalar,
	input wire par_err,
	input wire start_glitch,
	input wire stop_err,
	output reg data_samp_en,
	output reg edge_bit_cnt_en,
	output reg par_chk_en, stop_chk_en, start_chk_en,
	output reg deser_en,
	output reg data_valid
);

typedef enum bit [2:0] {
		IDLE   	     = 3'b000,
		CHK_START    = 3'b001,
		RECEIVE_BITS = 3'b011,
		CHK_PARITY   = 3'b010,
		CHK_STOP_P   = 3'b110,
		CHK_STOP_NP  = 3'b111,
		SEND_DATA    = 3'b101
} state;

state current_state,next_state;

wire sample_ready;
assign sample_ready = (edge_cnt == ((prescalar >> 1) + 3));

reg data_valid_comb;
always @(posedge clk or negedge rst) begin
	if(~rst) begin
		current_state <= IDLE;
		data_valid <= 1'b0;
	end 
	else begin
		current_state <= next_state;
		data_valid <= data_valid_comb;
	end
end

always @(*) begin
	data_samp_en = 1'b1;
	edge_bit_cnt_en = 1'b1;
	par_chk_en = 1'b0;
	stop_chk_en = 1'b0;
	start_chk_en = 1'b0;
	deser_en = 1'b0;
	data_valid_comb = 1'b0;
	case (current_state)
		IDLE      : begin
						if (~rx_in) begin
							next_state = CHK_START;
						end
						else begin
							next_state = IDLE;
							data_samp_en = 1'b0;
							edge_bit_cnt_en = 1'b0;
						end
			        end

		CHK_START : begin
						if (bit_cnt == 4'd1) begin
							if (start_glitch) begin
								next_state = IDLE;
								data_samp_en = 1'b0;
								edge_bit_cnt_en = 1'b0;
							end
							else begin
								next_state = RECEIVE_BITS;
								deser_en = 1'b1;
							end
						end
						else begin
							next_state = CHK_START;
							if (sample_ready) begin
								start_chk_en = 1'b1;
							end
							else begin
								start_chk_en = 1'b0;
							end
						end
			        end

	    RECEIVE_BITS: begin
	    				if (bit_cnt == 4'd9) begin
                    		if (par_en) begin
                        		next_state = CHK_PARITY;
                    		end
                    		else begin
                        		next_state = CHK_STOP_NP;
                    		end
                    		deser_en = 1'b0; // Disable deserializer after receiving all bits
                		end
                		else begin
                    		next_state = RECEIVE_BITS;
                    		if (sample_ready) begin
                        		deser_en = 1'b1;
                    		end
                    		else begin
                        		deser_en = 1'b0;
                    		end
                		end
	    			  end

		CHK_PARITY: begin
						if (bit_cnt == 4'd10) begin
							if (par_err) begin
								next_state = IDLE;
								data_samp_en = 1'b0;
								edge_bit_cnt_en = 1'b0;
							end
							else begin
								next_state = CHK_STOP_P;
							end
						end
						else begin
							next_state = CHK_PARITY;
							if (sample_ready) begin
                        		par_chk_en = 1'b1;
                    		end
                    		else begin
                        		par_chk_en = 1'b0;
                    		end
						end
			        end

		CHK_STOP_NP  : begin
						if (bit_cnt == 4'd9 && edge_cnt == prescalar) begin
							if (stop_err) begin
								next_state = IDLE;
								data_samp_en = 1'b0;
								edge_bit_cnt_en = 1'b0;
							end
							else begin
								next_state = SEND_DATA;
								data_valid_comb = 1'b1;
								data_samp_en = 1'b0;
								edge_bit_cnt_en = 1'b0;
							end
						end
						else begin
							next_state = CHK_STOP_NP;
							if (sample_ready) begin
								stop_chk_en = 1'b1;
							end
							else begin
								stop_chk_en = 1'b0;
							end
						end
			        end

		CHK_STOP_P  : begin
						if (bit_cnt == 4'd10 && edge_cnt == prescalar) begin
							if (stop_err) begin
								next_state = IDLE;
								data_samp_en = 1'b0;
								edge_bit_cnt_en = 1'b0;
							end
							else begin
								next_state = SEND_DATA;
								data_valid_comb = 1'b1;
								data_samp_en = 1'b0;
								edge_bit_cnt_en = 1'b0;
							end
						end
						else begin
							next_state = CHK_STOP_P;
							if (sample_ready) begin
								stop_chk_en = 1'b1;
							end
							else begin
								stop_chk_en = 1'b0;
							end
						end
					  end

		SEND_DATA : begin
						next_state = IDLE;
						data_samp_en = 1'b0;
						edge_bit_cnt_en = 1'b0;
			        end
			      
		default   : begin
						next_state = IDLE;
						data_samp_en = 1'b0;
						edge_bit_cnt_en = 1'b0;
			   	  	end
	endcase
end

endmodule

