module CLKDIV_MUX (
input wire [5:0] PreScale,
output reg [7:0] Div_Ratio
);


always @(*) begin
	case(PreScale) 
		6'b100000 : begin
						Div_Ratio = 'd1;				// Prescale equals 32
					end
		6'b010000 : begin
						Div_Ratio = 'd2;				// Prescale equals 16
					end	
		6'b001000 : begin
						Div_Ratio = 'd4;				// Prescale equals 8
					end
		default   : begin
						Div_Ratio = 'd1;				// Unsupported Prescale
					end					
	endcase
end	
    
  
endmodule