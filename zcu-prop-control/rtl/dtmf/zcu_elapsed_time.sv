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

// all signal in clk clock domain except for start

module zcu_elapsed_time
(
	input 	wire			clk,			// 100MHz clock
	input	wire			rst,			// system reset
	input	wire			clear,			// clear timer and wait for start
	input	wire			start,			// toggle to start timer
	output	reg		[23:0] 	elapsed			// milliseconds
);

reg run;
reg [16:0] prescale;
reg start_z, start_zz, start_zzz;

always @ (posedge clk)
begin
	if (rst)
	begin
		run <= 0;
		prescale <= 0;
		elapsed <= 0;
		start_z <= 0;
		start_zz <= 0;
		start_zzz <= 0;
	end
	else
	begin
		start_z <= start;			// metastable
		start_zz <= start_z;		// stable
		start_zzz <= start_zz;		// edge detect

		if (clear)
		begin
			run <= 0;
			prescale <= 0;
			elapsed <= 0;
		end
		else if (!run)
		begin
			if (start_zzz ^ start_zz)
			begin
				run <= 1;
				prescale <= 0;
				elapsed <= 0;
			end
		end
		else if (run)
		begin
			if (prescale == 99_999)
			begin
				prescale <= 0;
				elapsed <= elapsed + 1;
			end
			else
			begin
				prescale <= prescale + 1;
			end
		end
	end
end

endmodule
