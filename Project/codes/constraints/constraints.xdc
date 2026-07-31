## -------------------------------------------------------------------------
## System Clock (24 MHz)
## -------------------------------------------------------------------------
set_property PACKAGE_PIN D13 [get_ports clk_24mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_24mhz]
create_clock -period 41.667 [get_ports clk_24mhz]


## -------------------------------------------------------------------------
## Authentication LEDs (Bank 35)
## -------------------------------------------------------------------------
# Mapping led_green to LED1
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS33} [get_ports led_green]
# Mapping led_red to LED2
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports led_red]

## -------------------------------------------------------------------------
## 16x2 LCD Interface (Bank 35)
## LCD (16x2)
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports lcd_rs]
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS33} [get_ports lcd_rw]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports lcd_en]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {lcd_d[0]}]
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {lcd_d[1]}]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {lcd_d[2]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {lcd_d[3]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {lcd_d[4]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports {lcd_d[5]}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {lcd_d[6]}]
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {lcd_d[7]}]

## -------------------------------------------------------------------------
## USB-UART Interface
## -------------------------------------------------------------------------
# Replace 'PIN_X' with the actual pin connected to FT232H TX (FPGA RX)
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports uart_rx_pin]

# Replace 'PIN_Y' with the actual pin connected to FT232H RX (FPGA TX)
set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports uart_tx_pin]

## -------------------------------------------------------------------------
## System Reset (Mapped to Slide Switch SW0)
## -------------------------------------------------------------------------
## Temporarily mapping reset to Slide Switch 0 (SW0)
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports rst_pin]