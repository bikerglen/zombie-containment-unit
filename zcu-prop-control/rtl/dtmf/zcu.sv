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

module zcu #
(
	// Users to add parameters here

	// User parameters ends
	// Do not modify the parameters beyond this line


	// Parameters of Axi Slave Bus Interface S00_AXI
	parameter integer C_S00_AXI_DATA_WIDTH  = 32,
	parameter integer C_S00_AXI_ADDR_WIDTH  = 8
)
(
	// Users to add ports here
	
	// clocks
	input	wire			mclk,
	input	wire			mclk_pll_locked,

	// i2s interface to Analog SSM2603 codec
    output  wire            bclk,
    output  wire            pbdat,
	output	wire			pblrc,
    input   wire            recdat,
    output	wire            reclrc,
	output	wire			mute,

	// dtmf LEDs for debug
	output	wire	[4:0]	leds,

	// relay outputs
	output	reg		[3:0]	relays,

	// light / cluster light outputs
	output	wire	[7:0]	lights,

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

wire audio_out_mute;
wire [1:0] audio_out_select;
wire dtmf_in_select;
wire [5:0] axi_reg_leds;
wire [7:0] axi_reg_relays;
wire elapsed_time_clear;
wire [23:0] elapsed_time_time;
wire dtmf_fifo_rd;
wire [7:0] dtmf_fifo_rd_data;
wire dtmf_fifo_rd_not_empty;
reg timebase_flag;
wire timebase_flag_clear;

// Instantiation of Axi Bus Interface S00_AXI
zcu_S00_AXI # ( 
	.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
	.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
) zcu_S00_AXI_inst (
	// TODO -- add user ports here
	.audio_out_mute			(audio_out_mute),
	.audio_out_select		(audio_out_select),
	.dtmf_in_select			(dtmf_in_select),
	.axi_reg_leds			(axi_reg_leds),
	.axi_reg_relays			(axi_reg_relays),
	.elapsed_time_clear		(elapsed_time_clear),
	.elapsed_time_time		(elapsed_time_time),
	.dtmf_fifo_rd			(dtmf_fifo_rd),
	.dtmf_fifo_rd_data		(dtmf_fifo_rd_data),
	.dtmf_fifo_rd_not_empty	(dtmf_fifo_rd_not_empty),
	.timebase_flag			(timebase_flag),
	.timebase_flag_clear	(timebase_flag_clear),
	.lights					(lights),
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

// assert mclk_rst until s00_axi_aresetn is deasserted and mclk PLL is locked
reg mclk_rst, mclk_rst_0, mclk_rst_1, mclk_rst_2;

always @ (posedge mclk or negedge s00_axi_aresetn)
begin
	if (!s00_axi_aresetn)
	begin
		mclk_rst_0 <= 1; 
		mclk_rst_1 <= 1;
		mclk_rst_2 <= 1;
		mclk_rst <= 1;
	end
	else
	begin
		mclk_rst_0 <= !mclk_pll_locked; 
		mclk_rst_1 <= mclk_rst_0;
		mclk_rst_2 <= mclk_rst_1;
		mclk_rst <= mclk_rst_2;
	end
end

// assert aclk_rst until s00_axi_aresetn is deasserted
reg aclk_rst, aclk_rst_0, aclk_rst_1, aclk_rst_2;

always @ (posedge s00_axi_aclk or negedge s00_axi_aresetn)
begin
	if (!s00_axi_aresetn)
	begin
		aclk_rst_0 <= 1; 
		aclk_rst_1 <= 1;
		aclk_rst_2 <= 1;
		aclk_rst <= 1;
	end
	else
	begin
		aclk_rst_0 <= 0;
		aclk_rst_1 <= aclk_rst_0;
		aclk_rst_2 <= aclk_rst_1;
		aclk_rst <= aclk_rst_2;
	end
end


//----------------------------------------
// I2S interface
//----------------------------------------

wire pdout_ack;
reg [31:0] pdout_l, pdout_r;
wire pdin_req;
wire [31:0] pdin_l, pdin_r;

i2s_8kHz_i2s_format i2s_8kHz_i2s_format
(
    .mclk				(mclk),
    .rst				(mclk_rst),

    .lrclk				(lrclk),
    .bclk				(bclk),
    .sdout				(pbdat),
    .sdin				(recdat),

	// parallel data out to codec
    .pdout_ack			(pdout_ack),
    .pdout_l			(pdout_l),
    .pdout_r			(pdout_r),

	// parallel data in from codec
    .pdin_req			(pdin_req),
    .pdin_l				(pdin_l),
    .pdin_r				(pdin_r)
);

reg dtmf_in_valid;
reg [11:0] dtmf_in;

always @ (posedge mclk)
begin
	if (mclk_rst)
	begin
		pdout_l <= 0;
		pdout_r <= 0;
		dtmf_in_valid <= 0;
		dtmf_in <= 0;
	end
	else
	begin
		case (audio_out_select)

			0: begin					// mute
				pdout_l <= 0;
				pdout_r <= 0;
			end

			1: begin					// stereo
				pdout_l <= pdin_l;
				pdout_r <= pdin_r;
			end

			2: begin
				pdout_l <= pdin_l;		// dual-mono from left channel
				pdout_r <= pdin_l;
			end

			3: begin
				pdout_l <= pdin_r;		// dual-mono from right channel
				pdout_r <= pdin_r;
			end

		endcase

		case (dtmf_in_select)

			0: begin
				dtmf_in_valid <= pdin_req;		// use left audio for dtmf decoder
				dtmf_in <= pdin_l[31:20];		// 12 MSBs
			end

			1: begin
				dtmf_in_valid <= pdin_req;		// use right audio for dtmf decoder
				dtmf_in <= pdin_r[31:20];		// 12 MSBs
			end

		endcase
	end
end

assign pblrc = lrclk;
assign reclrc = lrclk;
assign mute = audio_out_mute;


//----------------------------------------
// DTMF decoder
//----------------------------------------

wire dtmf_valid;
wire [3:0] dtmf_data;
wire newKey;
wire [7:0] theKey;

dtmf dtmf
(
    .clk			(mclk),
    .rst			(mclk_rst),

    .valid			(dtmf_in_valid),
    .data			(dtmf_in),

    .newKey			(newKey),
    .theKey			(theKey),

	.dtmf_valid		(dtmf_valid),
	.dtmf_data      (dtmf_data)
);

// leds can come from register interface for testing or from dtmf decoder
assign leds = axi_reg_leds[5] ? axi_reg_leds[4:0] : { dtmf_valid, dtmf_data };


//----------------------------------------
// DTMF to AXI
//----------------------------------------

zcu_dtmf_fifo zcu_dtmf_fifo
(
	.rst			(aclk_rst),

	.wr_clk			(mclk),
	.wr_en			(newKey),
	.din			(theKey),
	.full			(),

	.rd_clk			(s00_axi_aclk),
	.rd_en			(dtmf_fifo_rd),
	.dout			(dtmf_fifo_rd_data),
	.empty			(dtmf_fifo_rd_empty)
);

assign dtmf_fifo_rd_not_empty = !dtmf_fifo_rd_empty;


//----------------------------------------
// DTMF to relays
//----------------------------------------

always @ (posedge mclk)
begin
	if (mclk_rst)
	begin
		relays <= 0;
	end
	else
	begin

		if (axi_reg_relays[1])
		begin
			relays[0] <= axi_reg_relays[0];
		end
		else if (dtmf_valid)
		begin
			if (dtmf_data == 1) relays[0] <= 1;
			else if (dtmf_data == 5) relays[0] <= 0;
		end

		if (axi_reg_relays[3])
		begin
			relays[1] <= axi_reg_relays[2];
		end
		else if (dtmf_valid)
		begin
			if (dtmf_data == 2) relays[1] <= 1;
			else if (dtmf_data == 6) relays[1] <= 0;
		end

		if (axi_reg_relays[5])
		begin
			relays[2] <= axi_reg_relays[4];
		end
		else if (dtmf_valid)
		begin
			if (dtmf_data == 3) relays[2] <= 1;
			else if (dtmf_data == 7) relays[2] <= 0;
		end

		if (axi_reg_relays[7])
		begin
			relays[3] <= axi_reg_relays[6];
		end
		else if (dtmf_valid)
		begin
			if (dtmf_data == 4) relays[3] <= 1;
			else if (dtmf_data == 8) relays[3] <= 0;
		end

	end
end


//----------------------------------------
// DTMF to program clock
//----------------------------------------

reg elapsed_time_start;

always @ (posedge mclk)
begin
	if (mclk_rst)
	begin
		elapsed_time_start <= 0;
	end
	else
	begin
		if (newKey && (theKey == "9"))
		begin
			elapsed_time_start <= !elapsed_time_start;
		end
	end
end

zcu_elapsed_time zcu_elapsed_time
(
	.clk			(s00_axi_aclk),
	.rst			(aclk_rst),
	.clear			(elapsed_time_clear),
	.start			(elapsed_time_start),
	.elapsed		(elapsed_time_time)
);


//----------------------------------------
// CPU main loop tasks timebase timer
//----------------------------------------

reg [23:0] timebase_counter;

always @ (posedge s00_axi_aclk)
begin
	if (aclk_rst)
	begin
		timebase_counter <= 0;
		timebase_flag <= 0;
	end
	else
	begin
		if (timebase_counter == 1_999_999)
		begin
			timebase_counter <= 0;
			timebase_flag <= 1;
		end
		else
		begin
			timebase_counter <= timebase_counter + 1;
			if (timebase_flag_clear)
			begin
				timebase_flag <= 0;
			end
		end
	end
end


//----------------------------------------
// ILA debug module
//----------------------------------------

ila_0 ila_0
(
	.clk			(mclk),
	.probe0			(dtmf_in),
	.probe1			(dtmf_in_valid),
	.probe2			(dtmf_valid),
	.probe3			(dtmf_data)
);

// User logic ends

endmodule
