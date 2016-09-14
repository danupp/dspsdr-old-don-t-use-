## Generated SDC file "trx.out.sdc"

## Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus Prime License Agreement,
## the Altera MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Altera and sold by Altera or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 15.1.0 Build 185 10/21/2015 SJ Lite Edition"

## DATE    "Thu Jan 21 21:11:03 2016"

##
## DEVICE  "EP4CE10E22C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk20} -period 50.000 -waveform { 0.000 25.000 } [get_ports {clk20}]
create_clock -name {ADC_clk} -period 800.000 -waveform { 0.000 25.000 } [get_nets {inst0|ADC_Clk}]
create_clock -name {rx_sample_clk} -period 25000.000 -waveform { 0.000 800.000 } [get_nets {inst6|clk_out}]
create_clock -name {FS_clk} -period 600000.000 -waveform { 0.000 300000.000 } [get_ports {CODEC_FS}]
create_clock -name {CODEC_Serial_clk} -period 1000.000 -waveform { 0.000 500.000 } [get_ports {CODEC_SCLK}]
create_clock -name {tx_rx_sample_clk} -period 25000.000 -waveform { 0.000 800.000 } [get_nets {inst8|clk_out}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {PLL_C0} -source [get_ports {clk20}] -multiply_by 12 -master_clock {clk20} [get_pins -compatibility_mode {*pll1|clk*}] 
create_generated_clock -name {B_clk_DAC} -source [get_pins -compatibility_mode {*pll1|clk*}] -divide_by 2 -master_clock {PLL_C0} [get_nets {*B_clk}] 
create_generated_clock -name {A_clk_DAC} -source [get_pins -compatibility_mode {*pll1|clk*}] -divide_by 2 -master_clock {PLL_C0} [get_nets {*A_clk}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {B_clk_DAC}] -rise_to [get_clocks {PLL_C0}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {B_clk_DAC}] -fall_to [get_clocks {PLL_C0}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {B_clk_DAC}] -rise_to [get_clocks {B_clk_DAC}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {B_clk_DAC}] -fall_to [get_clocks {B_clk_DAC}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {B_clk_DAC}] -rise_to [get_clocks {PLL_C0}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {B_clk_DAC}] -fall_to [get_clocks {PLL_C0}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {B_clk_DAC}] -rise_to [get_clocks {B_clk_DAC}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {B_clk_DAC}] -fall_to [get_clocks {B_clk_DAC}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {ADC_clk}] -rise_to [get_clocks {clk20}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {ADC_clk}] -fall_to [get_clocks {clk20}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {ADC_clk}] -rise_to [get_clocks {clk20}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {ADC_clk}] -fall_to [get_clocks {clk20}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CODEC_Serial_clk}] -rise_to [get_clocks {CODEC_Serial_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CODEC_Serial_clk}] -fall_to [get_clocks {CODEC_Serial_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CODEC_Serial_clk}] -rise_to [get_clocks {CODEC_Serial_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CODEC_Serial_clk}] -fall_to [get_clocks {CODEC_Serial_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {FS_clk}] -rise_to [get_clocks {CODEC_Serial_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {FS_clk}] -fall_to [get_clocks {CODEC_Serial_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {FS_clk}] -rise_to [get_clocks {CODEC_Serial_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {FS_clk}] -fall_to [get_clocks {CODEC_Serial_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {A_clk_DAC}] -rise_to [get_clocks {PLL_C0}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {A_clk_DAC}] -fall_to [get_clocks {PLL_C0}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {A_clk_DAC}] -rise_to [get_clocks {A_clk_DAC}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {A_clk_DAC}] -fall_to [get_clocks {A_clk_DAC}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {A_clk_DAC}] -rise_to [get_clocks {PLL_C0}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {A_clk_DAC}] -fall_to [get_clocks {PLL_C0}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {A_clk_DAC}] -rise_to [get_clocks {A_clk_DAC}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {A_clk_DAC}] -fall_to [get_clocks {A_clk_DAC}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_rx_sample_clk}] -rise_to [get_clocks {FS_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_rx_sample_clk}] -fall_to [get_clocks {FS_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_rx_sample_clk}] -rise_to [get_clocks {tx_rx_sample_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {tx_rx_sample_clk}] -fall_to [get_clocks {tx_rx_sample_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {tx_rx_sample_clk}] -rise_to [get_clocks {clk20}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {tx_rx_sample_clk}] -fall_to [get_clocks {clk20}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_rx_sample_clk}] -rise_to [get_clocks {FS_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_rx_sample_clk}] -fall_to [get_clocks {FS_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_rx_sample_clk}] -rise_to [get_clocks {tx_rx_sample_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {tx_rx_sample_clk}] -fall_to [get_clocks {tx_rx_sample_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {tx_rx_sample_clk}] -rise_to [get_clocks {clk20}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {tx_rx_sample_clk}] -fall_to [get_clocks {clk20}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk20}] -rise_to [get_clocks {ADC_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk20}] -fall_to [get_clocks {ADC_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk20}] -rise_to [get_clocks {tx_rx_sample_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk20}] -fall_to [get_clocks {tx_rx_sample_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk20}] -rise_to [get_clocks {clk20}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk20}] -fall_to [get_clocks {clk20}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk20}] -rise_to [get_clocks {ADC_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk20}] -fall_to [get_clocks {ADC_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk20}] -rise_to [get_clocks {tx_rx_sample_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk20}] -fall_to [get_clocks {tx_rx_sample_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk20}] -rise_to [get_clocks {clk20}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk20}] -fall_to [get_clocks {clk20}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

