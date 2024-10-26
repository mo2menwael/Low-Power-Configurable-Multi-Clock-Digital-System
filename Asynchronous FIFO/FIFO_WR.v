module FIFO_WR # (parameter ADDRESS_WIDTH = 3, ADDRESS_DEPTH = 8)
(
	input wire wclk,
	input wire wrst_n,
	input wire winc,
	input wire [ADDRESS_WIDTH:0] wq2_rptr,
	output wire wfull,
	output wire [ADDRESS_WIDTH-1:0] waddr,
	output reg [ADDRESS_WIDTH:0] wptr
);

reg [ADDRESS_WIDTH:0] wptr_non_gray;
// Convert to gray code
always @(posedge wclk or negedge wrst_n) begin
	if(~wrst_n) begin
    	wptr <= 0 ;
   	end
 	else begin
   		case (wptr_non_gray)
   			4'b0000: wptr <= 4'b0000;
   			4'b0001: wptr <= 4'b0001;
		    4'b0010: wptr <= 4'b0011;
		    4'b0011: wptr <= 4'b0010;
		    4'b0100: wptr <= 4'b0110;
		    4'b0101: wptr <= 4'b0111;
		    4'b0110: wptr <= 4'b0101;
		    4'b0111: wptr <= 4'b0100;
		    4'b1000: wptr <= 4'b1100;
		    4'b1001: wptr <= 4'b1101;
		    4'b1010: wptr <= 4'b1111;
		    4'b1011: wptr <= 4'b1110;
		    4'b1100: wptr <= 4'b1010;
		    4'b1101: wptr <= 4'b1011;
		    4'b1110: wptr <= 4'b1001;
		    4'b1111: wptr <= 4'b1000;
   		endcase
  	end
end

//assign wptr = wptr_non_gray ^ (wptr_non_gray >> 1); -> wrong as this is an input to a double FF synchronizer, and the input to a synchronizer must be
//														 reg not wire, as if it is a wire it will cause more meta stability  

assign wfull = ((wptr[1:0] == wq2_rptr[1:0]) && (wptr[2] != wq2_rptr[2]) && (wptr[3] != wq2_rptr[3]));

always @(posedge wclk or negedge wrst_n) begin
	if(~wrst_n) begin
		wptr_non_gray <= 'b0;
	end
	else if (winc && ~wfull) begin
		wptr_non_gray <= wptr_non_gray + 1;
	end
end

assign waddr = wptr_non_gray[ADDRESS_WIDTH-1:0];

endmodule
