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

// MCLK must be faster or equal to BCLK
// BCLK must be > sampling rate * word length * 2
// LRCLK must be sampling frequency

// MCLK  =  12.288 MHz
// LRCLK =   8.000 kHz
// BCLK  = 512.000 kHz
// 

module i2s_8kHz_i2s_format
(
	input	wire			mclk,
	input	wire			rst,


	output	reg				lrclk,
	output	reg				bclk,
	output	reg				sdout,
	input	wire			sdin,

	output	reg				pdout_ack,
	input	wire	[31:0]	pdout_l,
	input	wire	[31:0]	pdout_r,

	output	reg				pdin_req,
	output	reg		[31:0]	pdin_l,
	output	reg		[31:0]	pdin_r
);

reg [10:0] lrclk_divider;
reg [4:0] bclk_divider;
reg [5:0] bit_number;
reg [63:0] pdout;
reg [63:0] pdin;

always @ (posedge mclk)
begin
	if (rst)
	begin
		lrclk_divider <= 1535;
		bclk_divider <= 23;
		bit_number <= 0;
		lrclk <= 0;
		bclk <= 0;
		sdout <= 0;
		pdout <= 0;
		pdout_ack <= 0;
		pdin <= 0;
		pdin_req <= 0;
		pdin_l <= 0;
		pdin_r <= 0;
	end
	else
	begin
		if (lrclk_divider == 1535)
		begin
			lrclk_divider <= 0;
		end
		else
		begin
			lrclk_divider <= lrclk_divider + 1;
		end

		if (lrclk_divider == 23)
		begin
			bclk_divider <= 0;
			bit_number <= 63;
			pdout <= { pdout_l, pdout_r };
			pdout_ack <= 1;
		end
		else if (bclk_divider == 23)
		begin
			bclk_divider <= 0;
			bit_number <= bit_number - 1;
			pdout_ack <= 0;
		end
		else
		begin
			bclk_divider <= bclk_divider + 1;
			pdout_ack <= 0;
		end

		if (lrclk_divider == 0)
		begin
			lrclk <= 0;
		end
		else if (lrclk_divider == 767)
		begin
			lrclk <= 1;
		end

		if (bclk_divider == 0)
		begin
			bclk <= 0;
		end
		else if (bclk_divider == 11)
		begin
			bclk <= 1;
		end

		sdout <= pdout[bit_number];

		if (bclk_divider == 12)
		begin
			pdin <= { pdin[62:0], sdin };
		end

		if (lrclk_divider == 23)
		begin
			pdin_req <= 1;
			pdin_l <= pdin[63:32];	
			pdin_r <= pdin[31: 0];	
		end
		else
		begin
			pdin_req <= 0;
		end
	end

end

endmodule
