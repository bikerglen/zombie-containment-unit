set_property -dict { PACKAGE_PIN D18  IOSTANDARD LVCMOS33 } [get_ports { led[3] }];
set_property -dict { PACKAGE_PIN G14  IOSTANDARD LVCMOS33 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN M15  IOSTANDARD LVCMOS33 } [get_ports { led[1] }];
set_property -dict { PACKAGE_PIN M14  IOSTANDARD LVCMOS33 } [get_ports { led[0] }];

set_property -dict { PACKAGE_PIN T20  IOSTANDARD LVCMOS33 } [get_ports { re_n }]; #Sch=JB1_P / JB-1
set_property -dict { PACKAGE_PIN U20  IOSTANDARD LVCMOS33 } [get_ports { tx }]; #Sch=JB1_N / JB-2
set_property -dict { PACKAGE_PIN V20  IOSTANDARD LVCMOS33 } [get_ports { rx }]; #Sch=JB2_P / JB-3
set_property -dict { PACKAGE_PIN W20  IOSTANDARD LVCMOS33 } [get_ports { de }]; #Sch=JB2_N / JB-4

set_property -dict { PACKAGE_PIN Y18  IOSTANDARD LVCMOS33 } [get_ports { dmx_re_n }]; #Sch=JB3_P / JB-7        dmx universe 0 receive enable bar out
set_property -dict { PACKAGE_PIN Y19  IOSTANDARD LVCMOS33 } [get_ports { dmx_tx   }]; #Sch=JB3_N / JB-8        dmx universe 0 tx data out
set_property -dict { PACKAGE_PIN W18  IOSTANDARD LVCMOS33 } [get_ports { dmx_rx   }]; #Sch=JB4_P / JB-9        dmx universe 2 rx data in
set_property -dict { PACKAGE_PIN W19  IOSTANDARD LVCMOS33 } [get_ports { dmx_de   }]; #Sch=JB4_N / JB-10       dmx universe 3 driver enable out

set_property -dict { PACKAGE_PIN V15  IOSTANDARD LVCMOS33 DRIVE 4 } [get_ports { spi_out_0 }]; #Sch=JC1_P / JC-1
set_property -dict { PACKAGE_PIN W15  IOSTANDARD LVCMOS33 DRIVE 4 } [get_ports { spi_clk_0 }]; #Sch=JC1_N / JC-2
set_property -dict { PACKAGE_PIN T11  IOSTANDARD LVCMOS33 DRIVE 4 } [get_ports { spi_ss_n[0] }]; #Sch=JC2_P / JC-3
set_property -dict { PACKAGE_PIN T10  IOSTANDARD LVCMOS33 DRIVE 4 } [get_ports { spi_ss_n[1] }]; #Sch=JC2_N / JC-4

set_property -dict { PACKAGE_PIN W14  IOSTANDARD LVCMOS33 DRIVE 4 } [get_ports { spi_out_1 }]; #Sch=JC3_P / JC-7
set_property -dict { PACKAGE_PIN Y14  IOSTANDARD LVCMOS33 DRIVE 4 } [get_ports { spi_clk_1 }]; #Sch=JC3_N / JC-8
set_property -dict { PACKAGE_PIN T12  IOSTANDARD LVCMOS33 DRIVE 4 } [get_ports { spi_ss_n[2] }]; #Sch=JC4_P / JC-9
set_property -dict { PACKAGE_PIN U12  IOSTANDARD LVCMOS33 DRIVE 4 } [get_ports { spi_ss_n[3] }]; #Sch=JC4_N / JC-10

set_property -dict { PACKAGE_PIN T14  IOSTANDARD LVCMOS33 } [get_ports { lights[0] }]; #Sch=JD1_P / JD-1       cluster pilot light amber
set_property -dict { PACKAGE_PIN T15  IOSTANDARD LVCMOS33 } [get_ports { lights[1] }]; #Sch=JD1_N / JD-2       cluster pilot light green
set_property -dict { PACKAGE_PIN P14  IOSTANDARD LVCMOS33 } [get_ports { lights[2] }]; #Sch=JD2_P / JD-3       cluster pilot light blue
set_property -dict { PACKAGE_PIN R14  IOSTANDARD LVCMOS33 } [get_ports { lights[3] }]; #Sch=JD2_N / JD-4       cluster pilot light red

set_property -dict { PACKAGE_PIN U14  IOSTANDARD LVCMOS33 } [get_ports { lights[4] }]; #Sch=JD3_P / JD-7       danger light
set_property -dict { PACKAGE_PIN U15  IOSTANDARD LVCMOS33 } [get_ports { lights[5] }]; #Sch=JD3_N / JD-8       purge light
set_property -dict { PACKAGE_PIN V17  IOSTANDARD LVCMOS33 } [get_ports { relays[2] }]; #Sch=JD4_P / JD-9       red beacon (1 of 2)
set_property -dict { PACKAGE_PIN V18  IOSTANDARD LVCMOS33 } [get_ports { relays[3] }]; #Sch=JD4_N / JD-10      red beacon (2 of 2)

set_property -dict { PACKAGE_PIN V12  IOSTANDARD LVCMOS33 } [get_ports { relays[0] }]; #Sch=JE1_P / JE-1       right air cylinder
set_property -dict { PACKAGE_PIN W16  IOSTANDARD LVCMOS33 } [get_ports { relays[1] }]; #Sch=JE1_N / JE-2       left air cylinder
set_property -dict { PACKAGE_PIN J15  IOSTANDARD LVCMOS33 } [get_ports { lights[6] }]; #Sch=JE2_P / JE-3       yellow pilot light (1 of 2)
set_property -dict { PACKAGE_PIN H15  IOSTANDARD LVCMOS33 } [get_ports { lights[7] }]; #Sch=JE2_N / JE-4       yellow pilot light (2 of 2)

#set_property -dict { PACKAGE_PIN V13  IOSTANDARD LVCMOS33 } [get_ports { }]; #Sch=JE3_P / JE-7
#set_property -dict { PACKAGE_PIN U17  IOSTANDARD LVCMOS33 } [get_ports { }; #Sch=JE3_N / JE-8
#set_property -dict { PACKAGE_PIN T17  IOSTANDARD LVCMOS33 } [get_ports { }; #Sch=JE4_P / JE-9
#set_property -dict { PACKAGE_PIN Y17  IOSTANDARD LVCMOS33 } [get_ports { }; #Sch=JE4_N / JE-10

set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports bclk]; #IO_L12N_T1_MRCC_35 Sch=AC_BCLK
set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports mclk]; #IO_25_34 Sch=AC_MCLK
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports mute]; #IO_L23N_T3_34 Sch=AC_MUTEN
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports pbdat]; #IO_L8P_T1_AD10P_35 Sch=AC_PBDAT
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports pblrc]; #IO_L11N_T1_SRCC_35 Sch=AC_PBLRC
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports recdat]; #IO_L12P_T1_MRCC_35 Sch=AC_RECDAT
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports reclrc]; #IO_L8N_T1_AD10N_35 Sch=AC_RECLRC

set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports iic_scl_io]; #IO_L13P_T2_MRCC_34 Sch=AC_SCL
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports iic_sda_io]; #IO_L23P_T3_34 Sch=AC_SDA

set_clock_groups -asynchronous \
    -group [get_clocks {clk_fpga_0}] \
    -group [get_clocks {clk_out1_system_clk_wiz_0_0}]
