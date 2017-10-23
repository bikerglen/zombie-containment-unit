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

	module ws2811_16x128_v1_0_S00_AXI #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 8
	)
	(
		// Users to add ports here

		output	reg				ws_wr,
		output	reg		[11:0]	ws_wr_addr,
		output	reg		[31:0] 	ws_wr_data,
		output	reg		       	ws_gamma_en,
		output	reg		 [7:0]	ws_nleds_0,  
		output	reg		 [7:0]	ws_nleds_1,
		output	reg		 [7:0]	ws_nleds_2,
		output	reg		 [7:0]	ws_nleds_3,
		output	reg		 [7:0]  ws_nleds_4, 
		output	reg		 [7:0]  ws_nleds_5,
		output	reg		 [7:0]	ws_nleds_6,
		output	reg		 [7:0]	ws_nleds_7,
		output	reg		 [7:0]  ws_nleds_8, 
		output	reg		 [7:0]	ws_nleds_9,
		output	reg		 [7:0]	ws_nleds_10,
		output	reg		 [7:0]	ws_nleds_11,
		output	reg		 [7:0]  ws_nleds_12,
		output	reg		 [7:0]	ws_nleds_13,
		output	reg		 [7:0]	ws_nleds_14,
		output	reg		 [7:0]	ws_nleds_15,
		output	reg		[15:0]  ws_start, 
		output	reg		[15:0]  ws_bank,
		output	reg			    dmx0_wr,
		output	reg		 [8:0]  dmx0_wr_data,
		output	reg			    dmx1_wr,
		output	reg		 [8:0]  dmx1_wr_data,
		output	reg			    dmx2_wr,
		output	reg		 [8:0]  dmx2_wr_data,
		output	reg			    dmx3_wr,
		output	reg		 [8:0]  dmx3_wr_data,

		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 5;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 64
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	        end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

always @( posedge S_AXI_ACLK )
begin
	if ( S_AXI_ARESETN == 1'b0 )
	begin
		ws_gamma_en <= 0;
		ws_wr <= 0;
		ws_wr_addr <= 0;
		ws_wr_data <= 0;
		ws_nleds_0 <= 0;  
		ws_nleds_1 <= 0;
		ws_nleds_2 <= 0;
		ws_nleds_3 <= 0;
		ws_nleds_4 <= 0;
		ws_nleds_5 <= 0;
		ws_nleds_6 <= 0;
		ws_nleds_7 <= 0;
		ws_nleds_8 <= 0;
		ws_nleds_9 <= 0;
		ws_nleds_10 <= 0;
		ws_nleds_11 <= 0;
		ws_nleds_12 <= 0;
		ws_nleds_13 <= 0;
		ws_nleds_14 <= 0;
		ws_nleds_15 <= 0;
		ws_bank <= 0;
		ws_start <= 0;
		dmx0_wr <= 0;
		dmx0_wr_data <= 0;
		dmx1_wr <= 0;
		dmx1_wr_data <= 0;
		dmx2_wr <= 0;
		dmx2_wr_data <= 0;
		dmx3_wr <= 0;
		dmx3_wr_data <= 0;
	end 
	else
	begin
		ws_wr <= 0;
		ws_start <= 0;
		dmx0_wr <= 0;
		dmx1_wr <= 0;
		dmx2_wr <= 0;
		dmx3_wr <= 0;

		if (slv_reg_wren && (axi_awaddr[7:2] == 1))
		begin
			ws_wr_addr <= S_AXI_WDATA[11:0];
		end
		else if (ws_wr)
		begin
			ws_wr_addr <= ws_wr_addr + 1;
		end

		if (slv_reg_wren && (axi_awaddr[7:2] == 2))
		begin
			ws_wr <= 1;
			ws_wr_data <= S_AXI_WDATA[23:0];
		end

		if (slv_reg_wren && (axi_awaddr[7:2] == 3))
		begin
			ws_start <= S_AXI_WDATA[15:0];
		end

		if (slv_reg_wren && (axi_awaddr[7:2] == 'h20))
		begin
			dmx0_wr <= 1;
			dmx0_wr_data <= S_AXI_WDATA[8:0];
		end

		if (slv_reg_wren && (axi_awaddr[7:2] == 'h21))
		begin
			dmx1_wr <= 1;
			dmx1_wr_data <= S_AXI_WDATA[8:0];
		end

		if (slv_reg_wren && (axi_awaddr[7:2] == 'h22))
		begin
			dmx2_wr <= 1;
			dmx2_wr_data <= S_AXI_WDATA[8:0];
		end

		if (slv_reg_wren && (axi_awaddr[7:2] == 'h23))
		begin
			dmx3_wr <= 1;
			dmx3_wr_data <= S_AXI_WDATA[8:0];
		end

		if (slv_reg_wren)
		begin
			case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
				6'h00: ws_gamma_en <= S_AXI_WDATA[0];

				6'h04: begin
					ws_bank[0] <= S_AXI_WDATA[8];
					ws_nleds_0 <= S_AXI_WDATA[7:0];  
				end
				6'h05: begin
					ws_bank[1] <= S_AXI_WDATA[8];
					ws_nleds_1 <= S_AXI_WDATA[7:0];  
				end
				6'h06: begin
					ws_bank[2] <= S_AXI_WDATA[8];
					ws_nleds_2 <= S_AXI_WDATA[7:0];  
				end
				6'h07: begin
					ws_bank[3] <= S_AXI_WDATA[8];
					ws_nleds_3 <= S_AXI_WDATA[7:0];  
				end

				6'h08: begin
					ws_bank[4] <= S_AXI_WDATA[8];
					ws_nleds_4 <= S_AXI_WDATA[7:0];  
				end
				6'h09: begin
					ws_bank[5] <= S_AXI_WDATA[8];
					ws_nleds_5 <= S_AXI_WDATA[7:0];  
				end
				6'h0a: begin
					ws_bank[6] <= S_AXI_WDATA[8];
					ws_nleds_6 <= S_AXI_WDATA[7:0];  
				end
				6'h0b: begin
					ws_bank[7] <= S_AXI_WDATA[8];
					ws_nleds_7 <= S_AXI_WDATA[7:0];  
				end

				6'h0c: begin
					ws_bank[8] <= S_AXI_WDATA[8];
					ws_nleds_8 <= S_AXI_WDATA[7:0];  
				end
				6'h0d: begin
					ws_bank[9] <= S_AXI_WDATA[8];
					ws_nleds_9 <= S_AXI_WDATA[7:0];  
				end
				6'h0e: begin
					ws_bank[10] <= S_AXI_WDATA[8];
					ws_nleds_10 <= S_AXI_WDATA[7:0];  
				end
				6'h0f: begin
					ws_bank[11] <= S_AXI_WDATA[8];
					ws_nleds_11 <= S_AXI_WDATA[7:0];  
				end

				6'h10: begin
					ws_bank[12] <= S_AXI_WDATA[8];
					ws_nleds_12 <= S_AXI_WDATA[7:0];  
				end
				6'h11: begin
					ws_bank[13] <= S_AXI_WDATA[8];
					ws_nleds_13 <= S_AXI_WDATA[7:0];  
				end
				6'h12: begin
					ws_bank[14] <= S_AXI_WDATA[8];
					ws_nleds_14 <= S_AXI_WDATA[7:0];  
				end
				6'h13: begin
					ws_bank[15] <= S_AXI_WDATA[8];
					ws_nleds_15 <= S_AXI_WDATA[7:0];  
				end
	        endcase
		end
	end
end    

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;

always @(*)
begin
	// Address decoding for reading registers
	case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
		6'h00   : reg_data_out <= { 31'b0, ws_gamma_en };
		6'h04   : reg_data_out <= { 23'b0, ws_bank[ 0], ws_nleds_0 };
		6'h05   : reg_data_out <= { 23'b0, ws_bank[ 1], ws_nleds_1 };
		6'h06   : reg_data_out <= { 23'b0, ws_bank[ 2], ws_nleds_2 };
		6'h07   : reg_data_out <= { 23'b0, ws_bank[ 3], ws_nleds_3 };
		6'h08   : reg_data_out <= { 23'b0, ws_bank[ 4], ws_nleds_4 };
		6'h09   : reg_data_out <= { 23'b0, ws_bank[ 5], ws_nleds_5 };
		6'h0a   : reg_data_out <= { 23'b0, ws_bank[ 6], ws_nleds_6 };
		6'h0b   : reg_data_out <= { 23'b0, ws_bank[ 7], ws_nleds_7 };
		6'h0c   : reg_data_out <= { 23'b0, ws_bank[ 8], ws_nleds_8 };
		6'h0d   : reg_data_out <= { 23'b0, ws_bank[ 9], ws_nleds_9 };
		6'h0e   : reg_data_out <= { 23'b0, ws_bank[10], ws_nleds_10 };
		6'h0f   : reg_data_out <= { 23'b0, ws_bank[11], ws_nleds_11 };
		6'h10   : reg_data_out <= { 23'b0, ws_bank[12], ws_nleds_12 };
		6'h11   : reg_data_out <= { 23'b0, ws_bank[13], ws_nleds_13 };
		6'h12   : reg_data_out <= { 23'b0, ws_bank[14], ws_nleds_14 };
		6'h13   : reg_data_out <= { 23'b0, ws_bank[15], ws_nleds_15 };
		default : reg_data_out <= 0;
	endcase
end

// Output register or memory read data
always @( posedge S_AXI_ACLK )
begin
	if ( S_AXI_ARESETN == 1'b0 )
	begin
		axi_rdata  <= 0;
	end 
	else
	begin    
		// When there is a valid read address (S_AXI_ARVALID) with 
		// acceptance of read address by the slave (axi_arready), 
		// output the read dada 
		if (slv_reg_rden)
		begin
			axi_rdata <= reg_data_out;     // register read data
		end   
	end
end    

// Add user logic here

// User logic ends

endmodule
