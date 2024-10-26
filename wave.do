onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/RST_N
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/UART_CLK
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/REF_CLK
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/UART_RX_IN
add wave -noupdate -expand -group {DUT SIGNALS} -color {Orange Red} /SYS_TOP_tb/U_SYS_TOP/UART_TX_O
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/parity_error
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/framing_error
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/RX_Out_UnSync
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/RX_Valid_UnSync
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/RX_Out_Sync
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/RX_Valid_Sync
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/ALU_EN
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/ALU_FUN
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/CLK_Gate_EN
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/WrEn
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/RdEn
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/U_REG_FILE/RdData
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/Reg_file_Address
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/Reg_WrData
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/FIFO_WR_DATA
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/WR_INC
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/RX_DIV_RATIO
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/ALU_OUT
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/ALU_OUT_Valid
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/Reg_RdData
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/RdData_Valid
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/REG0
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/REG1
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/REG2
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/REG3
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/FULL
add wave -noupdate -expand -group {DUT SIGNALS} -color Gold /SYS_TOP_tb/U_SYS_TOP/EMPTY
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/FIFO_RD_DATA
add wave -noupdate -expand -group {DUT SIGNALS} -color Cyan /SYS_TOP_tb/U_SYS_TOP/Busy
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/RD_INC
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/ALU_CLK
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/TX_CLK
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/RX_CLK
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/SYNC_RST_REF
add wave -noupdate -expand -group {DUT SIGNALS} /SYS_TOP_tb/U_SYS_TOP/SYNC_RST_UART
add wave -noupdate /SYS_TOP_tb/U_SYS_TOP/U_REG_FILE/Register
add wave -noupdate -expand -group FSM /SYS_TOP_tb/U_SYS_TOP/U_SYS_CTRL/current_state
add wave -noupdate -expand -group FSM /SYS_TOP_tb/U_SYS_TOP/U_SYS_CTRL/next_state
add wave -noupdate -expand -group {SYS CTRL Signals} /SYS_TOP_tb/U_SYS_TOP/U_SYS_CTRL/TX_P_DATA
add wave -noupdate -expand -group {SYS CTRL Signals} /SYS_TOP_tb/U_SYS_TOP/U_SYS_CTRL/TX_D_VLD
add wave -noupdate -expand -group {FIFO Signals} /SYS_TOP_tb/U_SYS_TOP/U_ASYNC_FIFO/rptr
add wave -noupdate -expand -group {FIFO Signals} /SYS_TOP_tb/U_SYS_TOP/U_ASYNC_FIFO/U_FIFO_RD/rptr_non_gray
add wave -noupdate -expand -group {FIFO Signals} /SYS_TOP_tb/U_SYS_TOP/U_ASYNC_FIFO/wptr
add wave -noupdate -expand -group {FIFO Signals} /SYS_TOP_tb/U_SYS_TOP/U_ASYNC_FIFO/raddr
add wave -noupdate -expand -group {FIFO Signals} /SYS_TOP_tb/U_SYS_TOP/U_ASYNC_FIFO/waddr
add wave -noupdate -expand -group {FIFO Signals} /SYS_TOP_tb/U_SYS_TOP/U_ASYNC_FIFO/wq2_rptr
add wave -noupdate -expand -group {FIFO Signals} /SYS_TOP_tb/U_SYS_TOP/U_ASYNC_FIFO/rq2_wptr
add wave -noupdate -expand -group {Test_Bench Signals} /SYS_TOP_tb/Frame_1
add wave -noupdate -expand -group {Test_Bench Signals} /SYS_TOP_tb/Frame_2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1128877274 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 175
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {909725441 ps} {5476134029 ps}
