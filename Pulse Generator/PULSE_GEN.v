module PULSE_GEN (
input  wire CLK,
input  wire RST,
input  wire LVL_SIG,
output wire PULSE_SIG
);

reg Master_FF, Slave_FF;
					 
always @(posedge CLK or negedge RST)
 begin
    if(~RST) begin
        Master_FF <= 1'b0;
        Slave_FF  <= 1'b0;	
    end
    else begin
        Master_FF <= LVL_SIG;
        Slave_FF  <= Master_FF;
    end  
 end

assign PULSE_SIG = Master_FF && ~Slave_FF;

endmodule