module ASYNC_FIFO # (parameter DATA_WIDTH = 8, ADDRESS_WIDTH = 3, ADDRESS_DEPTH = 8, BUS_WIDTH = ADDRESS_WIDTH+1)
(
	input wire W_CLK, W_RST, W_INC,
	input wire R_CLK, R_RST, R_INC,
	input wire [DATA_WIDTH-1:0] WR_DATA,
	output wire [DATA_WIDTH-1:0] RD_DATA,
	output wire FULL, EMPTY
);

wire [ADDRESS_WIDTH:0] rptr;
wire [ADDRESS_WIDTH:0] wptr;

wire [ADDRESS_WIDTH-1:0] raddr;
wire [ADDRESS_WIDTH-1:0] waddr;

wire [ADDRESS_WIDTH:0] wq2_rptr;
wire [ADDRESS_WIDTH:0] rq2_wptr;

DF_SYNC #(.BUS_WIDTH(BUS_WIDTH)) sync_r2w (
.CLK  (W_CLK),
.RST  (W_RST),
.ASYNC(rptr),
.SYNC (wq2_rptr)
);

DF_SYNC #(.BUS_WIDTH(BUS_WIDTH)) sync_w2r (
.CLK  (R_CLK),
.RST  (R_RST),
.ASYNC(wptr),
.SYNC (rq2_wptr)
);

FIFO_MEM_CNTRL #(.ADDRESS_WIDTH(ADDRESS_WIDTH), .DATA_WIDTH(DATA_WIDTH), .ADDRESS_DEPTH(ADDRESS_DEPTH)) FIFO_Memory (
.wclk  (W_CLK),
.wrst  (W_RST),
.raddr (raddr),
.waddr (waddr),
.wdata (WR_DATA),
.wclken(W_INC & ~FULL),
.rdata (RD_DATA)
);

FIFO_RD #(.ADDRESS_WIDTH(ADDRESS_WIDTH), .ADDRESS_DEPTH(ADDRESS_DEPTH)) U_FIFO_RD (
.rclk    (R_CLK),
.rrst_n  (R_RST),
.raddr   (raddr),
.rptr    (rptr),
.rq2_wptr(rq2_wptr),
.rinc    (R_INC),
.rempty  (EMPTY)
);

FIFO_WR #(.ADDRESS_WIDTH(ADDRESS_WIDTH), .ADDRESS_DEPTH(ADDRESS_DEPTH)) U_FIFO_WR (
.wclk    (W_CLK),
.wrst_n  (W_RST),
.waddr   (waddr),
.wptr    (wptr),
.wq2_rptr(wq2_rptr),
.winc    (W_INC),
.wfull   (FULL)
);

endmodule
