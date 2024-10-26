
####################################################################################
# Constraints
# ----------------------------------------------------------------------------
#
# 0. Design Compiler variables
#
# 1. Master Clock Definitions
#
# 2. Generated Clock Definitions
#
# 3. Clock Uncertainties
#
# 4. Clock Latencies 
#
# 5. Clock Relationships
#
# 6. #set input/output delay on ports
#
# 7. Driving cells
#
# 8. Output load

####################################################################################
           #########################################################
                  #### Section 0 : DC Variables ####
           #########################################################
#################################################################################### 

# Prevent assign statements in the generated netlist (must be applied before compile command)
set_fix_multiple_port_nets -all -buffer_constants -feedthroughs

####################################################################################
           #########################################################
                  #### Section 1 : Clock Definition ####
           #########################################################
#################################################################################### 
# 1. Master Clock Definitions 
# 2. Generated Clock Definitions
# 3. Clock Latencies
# 4. Clock Uncertainties
# 4. Clock Transitions
####################################################################################

set REF_CLK_NAME REF_CLK
set REF_CLK_PER 20

set UART_CLK_NAME UART_CLK
set UART_CLK_PER 271.297

set SCAN_CLK_NAME SCAN_CLK
set SCAN_CLK_PER 10

set CLK_SETUP_SKEW 0.2
set CLK_HOLD_SKEW 0.1
set CLK_LAT 0
set CLK_RISE 0.05
set CLK_FALL 0.05

create_clock -name $REF_CLK_NAME -period $REF_CLK_PER -waveform "0 [expr $REF_CLK_PER/2]" [get_ports REF_CLK]
set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $REF_CLK_NAME]
set_clock_uncertainty -hold $CLK_HOLD_SKEW  [get_clocks $REF_CLK_NAME]
set_clock_transition -rise $CLK_RISE  [get_clocks $REF_CLK_NAME]
set_clock_transition -fall $CLK_FALL  [get_clocks $REF_CLK_NAME]
set_clock_latency $CLK_LAT [get_clocks $REF_CLK_NAME]


create_generated_clock -master_clock $REF_CLK_NAME -source [get_ports REF_CLK] \
                       -name "ALU_CLK" [get_port U_ALU/CLK] \
                       -divide_by 1
set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks "ALU_CLK"]
set_clock_uncertainty -hold $CLK_HOLD_SKEW  [get_clocks "ALU_CLK"]
set_clock_transition -rise $CLK_RISE  [get_clocks "ALU_CLK"]
set_clock_transition -fall $CLK_FALL  [get_clocks "ALU_CLK"]
set_clock_latency $CLK_LAT [get_clocks "ALU_CLK"]

####################################################################################

create_clock -name $UART_CLK_NAME -period $UART_CLK_PER -waveform "0 [expr $UART_CLK_PER/2]" [get_ports UART_CLK]
set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $UART_CLK_NAME]
set_clock_uncertainty -hold $CLK_HOLD_SKEW  [get_clocks $UART_CLK_NAME]
set_clock_transition -rise $CLK_RISE  [get_clocks $UART_CLK_NAME]
set_clock_transition -fall $CLK_FALL  [get_clocks $UART_CLK_NAME]
set_clock_latency $CLK_LAT [get_clocks $UART_CLK_NAME]

create_generated_clock -master_clock $UART_CLK_NAME -source [get_ports UART_CLK] \
                       -name "RX_CLK" [get_port U_UART_RX/CLK] \
                       -divide_by 1
set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks "RX_CLK"]
set_clock_uncertainty -hold $CLK_HOLD_SKEW  [get_clocks "RX_CLK"]
set_clock_transition -rise $CLK_RISE  [get_clocks "RX_CLK"]
set_clock_transition -fall $CLK_FALL  [get_clocks "RX_CLK"]
set_clock_latency $CLK_LAT [get_clocks "RX_CLK"]

create_generated_clock -master_clock $UART_CLK_NAME -source [get_ports UART_CLK] \
                       -name "TX_CLK" [get_port U_UART_TX/clk] \
                       -divide_by 32
set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks "TX_CLK"]
set_clock_uncertainty -hold $CLK_HOLD_SKEW  [get_clocks "TX_CLK"]
set_clock_transition -rise $CLK_RISE  [get_clocks "TX_CLK"]
set_clock_transition -fall $CLK_FALL  [get_clocks "TX_CLK"]
set_clock_latency $CLK_LAT [get_clocks "TX_CLK"]

####################################################################################

create_clock -name $SCAN_CLK_NAME -period $SCAN_CLK_PER -waveform "0 [expr $SCAN_CLK_PER/2]" [get_ports scan_clk]
set_clock_uncertainty -setup $CLK_SETUP_SKEW [get_clocks $SCAN_CLK_NAME]
set_clock_uncertainty -hold $CLK_HOLD_SKEW  [get_clocks $SCAN_CLK_NAME]
set_clock_transition -rise $CLK_RISE  [get_clocks $SCAN_CLK_NAME]
set_clock_transition -fall $CLK_FALL  [get_clocks $SCAN_CLK_NAME]
set_clock_latency $CLK_LAT [get_clocks $SCAN_CLK_NAME]

####################################################################################
		   
set_dont_touch_network [get_clocks {REF_CLK UART_CLK ALU_CLK RX_CLK TX_CLK SCAN_CLK}]

####################################################################################
           #########################################################
             #### Section 2 : Clocks Relationship ####
           #########################################################
####################################################################################

set_clock_groups -asynchronous -group [get_clocks "REF_CLK ALU_CLK"] -group [get_clocks "UART_CLK RX_CLK TX_CLK"]
set_clock_groups -asynchronous -group [get_clocks "SCAN_CLK"] -group [get_clocks "UART_CLK RX_CLK TX_CLK"]
set_clock_groups -asynchronous -group [get_clocks "SCAN_CLK"] -group [get_clocks "REF_CLK ALU_CLK"]

####################################################################################
           #########################################################
             #### Section 3 : #set input/output delay on ports ####
           #########################################################
####################################################################################

set in_delay  [expr 0.2*$UART_CLK_PER]
set out1_delay [expr 0.2*$UART_CLK_PER]
set out2_delay [expr 0.2*$UART_CLK_PER*32]

set dft_in_delay [expr 0.2*$SCAN_CLK_PER]
set dft_out_delay [expr 0.2*$SCAN_CLK_PER]

#Constrain Input Paths
set_input_delay $in_delay -clock RX_CLK [get_ports UART_RX_IN]

#Constrain Scan Input Paths
set_input_delay $dft_in_delay -clock $SCAN_CLK_NAME [get_ports {SI SE scan_clk scan_rst test_mode}]

#Constrain Output Paths
set_output_delay $out1_delay -clock RX_CLK [get_ports {parity_error framing_error}]
set_output_delay $out2_delay -clock TX_CLK [get_ports UART_TX_O]

#Constrain Scan Output Paths
set_output_delay $dft_out_delay -clock $SCAN_CLK_NAME [get_port SO]

####################################################################################
           #########################################################
                  #### Section 4 : Driving cells ####
           #########################################################
####################################################################################

#functional ports
set_driving_cell -library "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c" -lib_cell "BUFX2M" \
	-pin Y [get_ports UART_RX_IN]

#scan ports
set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_ports {SI SE scan_clk scan_rst test_mode}]

####################################################################################
           #########################################################
                  #### Section 5 : Output load ####
           #########################################################
####################################################################################

#functional ports
set_load 0.5 [get_ports {UART_TX_O parity_error framing_error}]

#scan ports
set_load 0.5 [get_port SO]

####################################################################################
           #########################################################
                 #### Section 6 : Operating Condition ####
           #########################################################
####################################################################################

# Define the Worst Library for Max(#setup) analysis
# Define the Best Library for Min(hold) analysis

set_operating_conditions -min_library "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -min "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" \
			-max_library "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c" -max "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c"

####################################################################################
           #########################################################
                  #### Section 7 : wireload Model ####
           #########################################################
####################################################################################


####################################################################################
           #########################################################
                  #### Section 8 : set_case_analysis ####
           #########################################################
####################################################################################

set_case_analysis 1 [get_port test_mode]

####################################################################################

