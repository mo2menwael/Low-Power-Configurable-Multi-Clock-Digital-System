module FIFO_RD # (parameter ADDRESS_WIDTH = 3, ADDRESS_DEPTH = 8)
(
	input wire rclk,
	input wire rrst_n,
	input wire rinc,
	input wire [ADDRESS_WIDTH:0] rq2_wptr,
	output wire rempty,
	output wire [ADDRESS_WIDTH-1:0] raddr,
	output reg [ADDRESS_WIDTH:0] rptr
);

reg [ADDRESS_WIDTH:0] rptr_non_gray;
// Convert to gray code
always @(posedge rclk or negedge rrst_n) begin
	if(~rrst_n) begin
    	rptr <= 0 ;
   	end
 	else begin
   		case (rptr_non_gray)
   			4'b0000: rptr <= 4'b0000;
   			4'b0001: rptr <= 4'b0001;
		    4'b0010: rptr <= 4'b0011;
		    4'b0011: rptr <= 4'b0010;
		    4'b0100: rptr <= 4'b0110;
		    4'b0101: rptr <= 4'b0111;
		    4'b0110: rptr <= 4'b0101;
		    4'b0111: rptr <= 4'b0100;
		    4'b1000: rptr <= 4'b1100;
		    4'b1001: rptr <= 4'b1101;
		    4'b1010: rptr <= 4'b1111;
		    4'b1011: rptr <= 4'b1110;
		    4'b1100: rptr <= 4'b1010;
		    4'b1101: rptr <= 4'b1011;
		    4'b1110: rptr <= 4'b1001;
		    4'b1111: rptr <= 4'b1000;
   		endcase
  	end
end

//assign rptr = rptr_non_gray ^ (rptr_non_gray >> 1); -> wrong as this is an input to a double FF synchronizer, and the input to a synchronizer must be
//														 reg not wire, as if it is a wire it will cause more meta stability  


assign rempty = (rptr == rq2_wptr);

always @(posedge rclk or negedge rrst_n) begin
	if(~rrst_n) begin
		rptr_non_gray <= 'b0;
	end
	else if (rinc && ~rempty) begin
		rptr_non_gray <= rptr_non_gray + 1;
	end
end

assign raddr = rptr_non_gray[ADDRESS_WIDTH-1:0];

endmodule
