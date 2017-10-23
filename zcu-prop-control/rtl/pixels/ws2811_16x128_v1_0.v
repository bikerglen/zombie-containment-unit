//=============================================================================================
// Zombie Containment Unit
// Copyright 2017 by Glen Akins.
// All rights reserved.
// 
// Set editor tab stop to 4.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//=============================================================================================


`timescale 1 ns / 1 ps

	module ws2811_16x128_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 8
	)
	(
		// Users to add ports here

		input	wire			clk20,
		input	wire			clk20_pll_locked,
		output	wire	[15:0]	tx_out,
		output	wire	 [3:0]	dmx_out,

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);

	wire        ws_wr;
	wire [11:0] ws_wr_addr;
	wire [31:0] ws_wr_data;
	wire        ws_gamma_en;
	wire  [7:0]	ws_nleds_0,  ws_nleds_1,  ws_nleds_2,  ws_nleds_3;
	wire  [7:0]	ws_nleds_4,  ws_nleds_5,  ws_nleds_6,  ws_nleds_7;
	wire  [7:0]	ws_nleds_8,  ws_nleds_9,  ws_nleds_10, ws_nleds_11;
	wire  [7:0]	ws_nleds_12, ws_nleds_13, ws_nleds_14, ws_nleds_15;
	wire [15:0] ws_start, ws_bank;

	wire       dmx0_wr;
	wire       dmx1_wr;
	wire       dmx2_wr;
	wire       dmx3_wr;
	wire [8:0] dmx0_wr_data;
	wire [8:0] dmx1_wr_data;
	wire [8:0] dmx2_wr_data;
	wire [8:0] dmx3_wr_data;

// Instantiation of Axi Bus Interface S00_AXI
	ws2811_16x128_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) ws2811_16x128_v1_0_S00_AXI_inst (
        .ws_wr				(ws_wr),
        .ws_wr_addr			(ws_wr_addr),   
        .ws_wr_data			(ws_wr_data),
        .ws_gamma_en		(ws_gamma_en),
        .ws_nleds_0 		(ws_nleds_0),
        .ws_nleds_1 		(ws_nleds_1),
        .ws_nleds_2			(ws_nleds_2),
        .ws_nleds_3			(ws_nleds_3),
        .ws_nleds_4			(ws_nleds_4), 
        .ws_nleds_5			(ws_nleds_5),
        .ws_nleds_6			(ws_nleds_6),
        .ws_nleds_7			(ws_nleds_7),
        .ws_nleds_8			(ws_nleds_8),
        .ws_nleds_9			(ws_nleds_9),
        .ws_nleds_10		(ws_nleds_10),
        .ws_nleds_11		(ws_nleds_11),
        .ws_nleds_12		(ws_nleds_12),
        .ws_nleds_13		(ws_nleds_13),
        .ws_nleds_14		(ws_nleds_14),
        .ws_nleds_15		(ws_nleds_15),
        .ws_start 			(ws_start),
        .ws_bank			(ws_bank),
		.dmx0_wr			(dmx0_wr),
		.dmx0_wr_data		(dmx0_wr_data),
		.dmx1_wr			(dmx1_wr),
		.dmx1_wr_data		(dmx1_wr_data),
		.dmx2_wr			(dmx2_wr),
		.dmx2_wr_data		(dmx2_wr_data),
		.dmx3_wr			(dmx3_wr),
		.dmx3_wr_data		(dmx3_wr_data),
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here

	// assert clk20_rst until s00_axi_aresetn is deasserted and clk20 PLL is locked
	reg clk20_rst, rst_0, rst_1, rst_2;

	always @ (posedge clk20 or negedge s00_axi_aresetn)
	begin
		if (!s00_axi_aresetn)
		begin
			rst_0 <= 1; 
			rst_1 <= 1;
			rst_2 <= 1;
			clk20_rst <= 1;
		end
		else
		begin
			rst_0 <= !clk20_pll_locked; 
			rst_1 <= rst_0;
			rst_2 <= rst_1;
			clk20_rst <= rst_2;
		end
	end

	// gamma correct red, green, and blue channels
	wire [7:0] gc_red, gc_green, gc_blue;

	ws2811_gamma ws2811_gamma_red
	(
		.din			(ws_wr_data[23:16]),
		.dout			(gc_red)
	);

	ws2811_gamma ws2811_gamma_green
	(
		.din			(ws_wr_data[15:8]),
		.dout			(gc_green)
	);

	ws2811_gamma ws2811_gamma_blue
	(
		.din			(ws_wr_data[7:0]),
		.dout			(gc_blue)
	);

	// select uncorrected or gamma corrected data to write to memories
    wire [23:0] ws_wr_data_gc = ws_gamma_en ? { gc_red, gc_green, gc_blue } : ws_wr_data[23:0];

	// create wr enables for each string's controller
	wire ws_wr_0  = ws_wr && (ws_wr_addr[11:8] ==  0);
	wire ws_wr_1  = ws_wr && (ws_wr_addr[11:8] ==  1);
	wire ws_wr_2  = ws_wr && (ws_wr_addr[11:8] ==  2);
	wire ws_wr_3  = ws_wr && (ws_wr_addr[11:8] ==  3);
	wire ws_wr_4  = ws_wr && (ws_wr_addr[11:8] ==  4);
	wire ws_wr_5  = ws_wr && (ws_wr_addr[11:8] ==  5);
	wire ws_wr_6  = ws_wr && (ws_wr_addr[11:8] ==  6);
	wire ws_wr_7  = ws_wr && (ws_wr_addr[11:8] ==  7);
	wire ws_wr_8  = ws_wr && (ws_wr_addr[11:8] ==  8);
	wire ws_wr_9  = ws_wr && (ws_wr_addr[11:8] ==  9);
	wire ws_wr_10 = ws_wr && (ws_wr_addr[11:8] == 10);
	wire ws_wr_11 = ws_wr && (ws_wr_addr[11:8] == 11);
	wire ws_wr_12 = ws_wr && (ws_wr_addr[11:8] == 12);
	wire ws_wr_13 = ws_wr && (ws_wr_addr[11:8] == 13);
	wire ws_wr_14 = ws_wr && (ws_wr_addr[11:8] == 14);
	wire ws_wr_15 = ws_wr && (ws_wr_addr[11:8] == 15);

	ws2811_128 ws2811_128_0
	(
		.wr_clk			(s00_axi_aclk),			// write clock
		.wr_rst_n		(s00_axi_aresetn),		// reset in write clock domain

		.wr				(ws_wr_0),				// write enable 
		.wr_addr		(ws_wr_addr[7:0]),		// two banks of up to 128 LEDS
		.wr_data		(ws_wr_data_gc),		// { R[7:0],G[7:0],B[7:0] }

		.bank			(ws_bank[0]),			// bank to transmit
		.leds			(ws_nleds_0),			// number of LEDs to transmit, 1 to 128	
		.start			(ws_start[0]),			// begin transmission

		.rst			(clk20_rst),			// synchronous active-high reset
		.clk			(clk20),				// 20MHz clock
		.tx_out			(tx_out[0])				// transmit data out
	);

	ws2811_128 ws2811_128_1
	(
		.wr_clk			(s00_axi_aclk),			// write clock
		.wr_rst_n		(s00_axi_aresetn),		// reset in write clock domain

		.wr				(ws_wr_1),				// write enable 
		.wr_addr		(ws_wr_addr[7:0]),		// two banks of up to 128 LEDS
		.wr_data		(ws_wr_data_gc),		// { R[7:0],G[7:0],B[7:0] }

		.bank			(ws_bank[1]),			// bank to transmit
		.leds			(ws_nleds_1),			// number of LEDs to transmit, 1 to 128	
		.start			(ws_start[1]),			// begin transmission

		.rst			(clk20_rst),			// synchronous active-high reset
		.clk			(clk20),				// 20MHz clock
		.tx_out			(tx_out[1])				// transmit data out
	);

	ws2811_128 ws2811_128_2
	(
		.wr_clk			(s00_axi_aclk),			// write clock
		.wr_rst_n		(s00_axi_aresetn),		// reset in write clock domain

		.wr				(ws_wr_2),				// write enable 
		.wr_addr		(ws_wr_addr[7:0]),		// two banks of up to 128 LEDS
		.wr_data		(ws_wr_data_gc),		// { R[7:0],G[7:0],B[7:0] }

		.bank			(ws_bank[2]),			// bank to transmit
		.leds			(ws_nleds_2),			// number of LEDs to transmit, 1 to 128	
		.start			(ws_start[2]),			// begin transmission

		.rst			(clk20_rst),			// synchronous active-high reset
		.clk			(clk20),				// 20MHz clock
		.tx_out			(tx_out[2])				// transmit data out
	);

	ws2811_128 ws2811_128_3
	(
		.wr_clk			(s00_axi_aclk),			// write clock
		.wr_rst_n		(s00_axi_aresetn),		// reset in write clock domain

		.wr				(ws_wr_3),				// write enable 
		.wr_addr		(ws_wr_addr[7:0]),		// two banks of up to 128 LEDS
		.wr_data		(ws_wr_data_gc),		// { R[7:0],G[7:0],B[7:0] }

		.bank			(ws_bank[3]),			// bank to transmit
		.leds			(ws_nleds_3),			// number of LEDs to transmit, 1 to 128	
		.start			(ws_start[3]),			// begin transmission

		.rst			(clk20_rst),			// synchronous active-high reset
		.clk			(clk20),				// 20MHz clock
		.tx_out			(tx_out[3])				// transmit data out
	);

	ws2811_128 ws2811_128_4
	(
		.wr_clk			(s00_axi_aclk),			// write clock
		.wr_rst_n		(s00_axi_aresetn),		// reset in write clock domain

		.wr				(ws_wr_4),				// write enable 
		.wr_addr		(ws_wr_addr[7:0]),		// two banks of up to 128 LEDS
		.wr_data		(ws_wr_data_gc),		// { R[7:0],G[7:0],B[7:0] }

		.bank			(ws_bank[4]),			// bank to transmit
		.leds			(ws_nleds_4),			// number of LEDs to transmit, 1 to 128	
		.start			(ws_start[4]),			// begin transmission

		.rst			(clk20_rst),			// synchronous active-high reset
		.clk			(clk20),				// 20MHz clock
		.tx_out			(tx_out[4])				// transmit data out
	);

	ws2811_128 ws2811_128_5
	(
		.wr_clk			(s00_axi_aclk),			// write clock
		.wr_rst_n		(s00_axi_aresetn),		// reset in write clock domain

		.wr				(ws_wr_5),				// write enable 
		.wr_addr		(ws_wr_addr[7:0]),		// two banks of up to 128 LEDS
		.wr_data		(ws_wr_data_gc),		// { R[7:0],G[7:0],B[7:0] }

		.bank			(ws_bank[5]),			// bank to transmit
		.leds			(ws_nleds_5),			// number of LEDs to transmit, 1 to 128	
		.start			(ws_start[5]),			// begin transmission

		.rst			(clk20_rst),			// synchronous active-high reset
		.clk			(clk20),				// 20MHz clock
		.tx_out			(tx_out[5])				// transmit data out
	);

	ws2811_128 ws2811_128_6
	(
		.wr_clk			(s00_axi_aclk),			// write clock
		.wr_rst_n		(s00_axi_aresetn),		// reset in write clock domain

		.wr				(ws_wr_6),				// write enable 
		.wr_addr		(ws_wr_addr[7:0]),		// two banks of up to 128 LEDS
		.wr_data		(ws_wr_data_gc),		// { R[7:0],G[7:0],B[7:0] }

		.bank			(ws_bank[6]),			// bank to transmit
		.leds			(ws_nleds_6),			// number of LEDs to transmit, 1 to 128	
		.start			(ws_start[6]),			// begin transmission

		.rst			(clk20_rst),			// synchronous active-high reset
		.clk			(clk20),				// 20MHz clock
		.tx_out			(tx_out[6])				// transmit data out
	);

	ws2811_128 ws2811_128_7
	(
		.wr_clk			(s00_axi_aclk),			// write clock
		.wr_rst_n		(s00_axi_aresetn),		// reset in write clock domain

		.wr				(ws_wr_7),				// write enable 
		.wr_addr		(ws_wr_addr[7:0]),		// two banks of up to 128 LEDS
		.wr_data		(ws_wr_data_gc),		// { R[7:0],G[7:0],B[7:0] }

		.bank			(ws_bank[7]),			// bank to transmit
		.leds			(ws_nleds_7),			// number of LEDs to transmit, 1 to 128	
		.start			(ws_start[7]),			// begin transmission

		.rst			(clk20_rst),			// synchronous active-high reset
		.clk			(clk20),				// 20MHz clock
		.tx_out			(tx_out[7])				// transmit data out
	);

	ws2811_128 ws2811_128_8
	(
		.wr_clk			(s00_axi_aclk),			// write clock
		.wr_rst_n		(s00_axi_aresetn),		// reset in write clock domain

		.wr				(ws_wr_8),				// write enable 
		.wr_addr		(ws_wr_addr[7:0]),		// two banks of up to 128 LEDS
		.wr_data		(ws_wr_data_gc),		// { R[7:0],G[7:0],B[7:0] }

		.bank			(ws_bank[8]),			// bank to transmit
		.leds			(ws_nleds_8),			// number of LEDs to transmit, 1 to 128	
		.start			(ws_start[8]),			// begin transmission

		.rst			(clk20_rst),			// synchronous active-high reset
		.clk			(clk20),				// 20MHz clock
		.tx_out			(tx_out[8])				// transmit data out
	);

	ws2811_128 ws2811_128_9
	(
		.wr_clk			(s00_axi_aclk),			// write clock
		.wr_rst_n		(s00_axi_aresetn),		// reset in write clock domain

		.wr				(ws_wr_9),				// write enable 
		.wr_addr		(ws_wr_addr[7:0]),		// two banks of up to 128 LEDS
		.wr_data		(ws_wr_data_gc),		// { R[7:0],G[7:0],B[7:0] }

		.bank			(ws_bank[9]),			// bank to transmit
		.leds			(ws_nleds_9),			// number of LEDs to transmit, 1 to 128	
		.start			(ws_start[9]),			// begin transmission

		.rst			(clk20_rst),			// synchronous active-high reset
		.clk			(clk20),				// 20MHz clock
		.tx_out			(tx_out[9])				// transmit data out
	);

	ws2811_128 ws2811_128_10
	(
		.wr_clk			(s00_axi_aclk),			// write clock
		.wr_rst_n		(s00_axi_aresetn),		// reset in write clock domain

		.wr				(ws_wr_10),				// write enable 
		.wr_addr		(ws_wr_addr[7:0]),		// two banks of up to 128 LEDS
		.wr_data		(ws_wr_data_gc),		// { R[7:0],G[7:0],B[7:0] }

		.bank			(ws_bank[10]),			// bank to transmit
		.leds			(ws_nleds_10),			// number of LEDs to transmit, 1 to 128	
		.start			(ws_start[10]),			// begin transmission

		.rst			(clk20_rst),			// synchronous active-high reset
		.clk			(clk20),				// 20MHz clock
		.tx_out			(tx_out[10])			// transmit data out
	);

	ws2811_128 ws2811_128_11
	(
		.wr_clk			(s00_axi_aclk),			// write clock
		.wr_rst_n		(s00_axi_aresetn),		// reset in write clock domain

		.wr				(ws_wr_11),				// write enable 
		.wr_addr		(ws_wr_addr[7:0]),		// two banks of up to 128 LEDS
		.wr_data		(ws_wr_data_gc),		// { R[7:0],G[7:0],B[7:0] }

		.bank			(ws_bank[11]),			// bank to transmit
		.leds			(ws_nleds_11),			// number of LEDs to transmit, 1 to 128	
		.start			(ws_start[11]),			// begin transmission

		.rst			(clk20_rst),			// synchronous active-high reset
		.clk			(clk20),				// 20MHz clock
		.tx_out			(tx_out[11])			// transmit data out
	);

	ws2811_128 ws2811_128_12
	(
		.wr_clk			(s00_axi_aclk),			// write clock
		.wr_rst_n		(s00_axi_aresetn),		// reset in write clock domain

		.wr				(ws_wr_12),				// write enable 
		.wr_addr		(ws_wr_addr[7:0]),		// two banks of up to 128 LEDS
		.wr_data		(ws_wr_data_gc),		// { R[7:0],G[7:0],B[7:0] }

		.bank			(ws_bank[12]),			// bank to transmit
		.leds			(ws_nleds_12),			// number of LEDs to transmit, 1 to 128	
		.start			(ws_start[12]),			// begin transmission

		.rst			(clk20_rst),			// synchronous active-high reset
		.clk			(clk20),				// 20MHz clock
		.tx_out			(tx_out[12])			// transmit data out
	);

	ws2811_128 ws2811_128_13
	(
		.wr_clk			(s00_axi_aclk),			// write clock
		.wr_rst_n		(s00_axi_aresetn),		// reset in write clock domain

		.wr				(ws_wr_13),				// write enable 
		.wr_addr		(ws_wr_addr[7:0]),		// two banks of up to 128 LEDS
		.wr_data		(ws_wr_data_gc),		// { R[7:0],G[7:0],B[7:0] }

		.bank			(ws_bank[13]),			// bank to transmit
		.leds			(ws_nleds_13),			// number of LEDs to transmit, 1 to 128	
		.start			(ws_start[13]),			// begin transmission

		.rst			(clk20_rst),			// synchronous active-high reset
		.clk			(clk20),				// 20MHz clock
		.tx_out			(tx_out[13])			// transmit data out
	);

	ws2811_128 ws2811_128_14
	(
		.wr_clk			(s00_axi_aclk),			// write clock
		.wr_rst_n		(s00_axi_aresetn),		// reset in write clock domain

		.wr				(ws_wr_14),				// write enable 
		.wr_addr		(ws_wr_addr[7:0]),		// two banks of up to 128 LEDS
		.wr_data		(ws_wr_data_gc),		// { R[7:0],G[7:0],B[7:0] }

		.bank			(ws_bank[14]),			// bank to transmit
		.leds			(ws_nleds_14),			// number of LEDs to transmit, 1 to 128	
		.start			(ws_start[14]),			// begin transmission

		.rst			(clk20_rst),			// synchronous active-high reset
		.clk			(clk20),				// 20MHz clock
		.tx_out			(tx_out[14])			// transmit data out
	);

	ws2811_128 ws2811_128_15
	(
		.wr_clk			(s00_axi_aclk),			// write clock
		.wr_rst_n		(s00_axi_aresetn),		// reset in write clock domain

		.wr				(ws_wr_15),				// write enable 
		.wr_addr		(ws_wr_addr[7:0]),		// two banks of up to 128 LEDS
		.wr_data		(ws_wr_data_gc),		// { R[7:0],G[7:0],B[7:0] }

		.bank			(ws_bank[15]),			// bank to transmit
		.leds			(ws_nleds_15),			// number of LEDs to transmit, 1 to 128	
		.start			(ws_start[15]),			// begin transmission

		.rst			(clk20_rst),			// synchronous active-high reset
		.clk			(clk20),				// 20MHz clock
		.tx_out			(tx_out[15])			// transmit data out
	);

	dmx dmx_0
	(
		.rst					(clk20_rst),
		.clk					(clk20),
		.dmx_txd				(dmx_out[0]),
    	.dmx_tx_fifo_clk		(s00_axi_aclk),
    	.dmx_tx_fifo_full		(), // NC
    	.dmx_tx_fifo_wr			(dmx0_wr),
    	.dmx_tx_fifo_wr_data	(dmx0_wr_data)
	);

	dmx dmx_1
	(
		.rst					(clk20_rst),
		.clk					(clk20),
		.dmx_txd				(dmx_out[1]),
    	.dmx_tx_fifo_clk		(s00_axi_aclk),
    	.dmx_tx_fifo_full		(), // NC
    	.dmx_tx_fifo_wr			(dmx1_wr),
    	.dmx_tx_fifo_wr_data	(dmx1_wr_data)
	);

	dmx dmx_2
	(
		.rst					(clk20_rst),
		.clk					(clk20),
		.dmx_txd				(dmx_out[2]),
    	.dmx_tx_fifo_clk		(s00_axi_aclk),
    	.dmx_tx_fifo_full		(), // NC
    	.dmx_tx_fifo_wr			(dmx2_wr),
    	.dmx_tx_fifo_wr_data	(dmx2_wr_data)
	);

	dmx dmx_3
	(
		.rst					(clk20_rst),
		.clk					(clk20),
		.dmx_txd				(dmx_out[3]),
    	.dmx_tx_fifo_clk		(s00_axi_aclk),
    	.dmx_tx_fifo_full		(), // NC
    	.dmx_tx_fifo_wr			(dmx3_wr),
    	.dmx_tx_fifo_wr_data	(dmx3_wr_data)
	);

	// User logic ends

	endmodule
