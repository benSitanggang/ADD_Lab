set_property PACKAGE_PIN U18 [get_ports {clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]
create_clock -period 20.000 -waveform {0.000 10.000} [get_ports clk]

set_property PACKAGE_PIN N15 [get_ports resetn] # PL KEY 1
set_property IOSTANDARD LVCMOS33 [get_ports resetn]

set_property PACKAGE_PIN N16 [get_ports btn[0]] # PL KEY 2, SINGLE button
set_property IOSTANDARD LVCMOS33 [get_ports btn[0]]

set_property PACKAGE_PIN T17 [get_ports btn[1]] # PL KEY 3, Forced Mode toggle
set_property IOSTANDARD LVCMOS33 [get_ports btn[1]]

set_property PACKAGE_PIN R17 [get_ports btn[2]] # PL KEY 4, unused
set_property IOSTANDARD LVCMOS33 [get_ports btn[2]]

set_property PACKAGE_PIN M14 [get_ports triggerCh1] # LED1
set_property IOSTANDARD LVCMOS33 [get_ports triggerCh1]

set_property PACKAGE_PIN M15 [get_ports triggerCh2] # LED2
set_property IOSTANDARD LVCMOS33 [get_ports triggerCh2]

set_property PACKAGE_PIN K16 [get_ports conversionPlusReadoutTime] # LED3
set_property IOSTANDARD LVCMOS33 [get_ports conversionPlusReadoutTime]

set_property PACKAGE_PIN J16 [get_ports sampleTimerRollover] # LED4
set_property IOSTANDARD LVCMOS33 [get_ports sampleTimerRollover]

