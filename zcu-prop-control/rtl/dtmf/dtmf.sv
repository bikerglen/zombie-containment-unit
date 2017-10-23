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

module dtmf
(
	input	wire			clk,
	input	wire			rst,

	input	wire			valid,
	input	wire	[11:0]	data,

	output	reg				newKey,
	output	reg		 [7:0]	theKey,

	output	reg				dtmf_valid,
	output	reg		 [3:0]	dtmf_data
);

reg [7:0] count;
reg first;

reg iir_outs_valid;
reg [19:0] r1_q1_r, r1_q2_r;
reg [19:0] r2_q1_r, r2_q2_r;
reg [19:0] r3_q1_r, r3_q2_r;
reg [19:0] r4_q1_r, r4_q2_r;
reg [19:0] c1_q1_r, c1_q2_r;
reg [19:0] c2_q1_r, c2_q2_r;
reg [19:0] c3_q1_r, c3_q2_r;
reg [19:0] c4_q1_r, c4_q2_r;
wire [19:0] r1_q1, r1_q2;
wire [19:0] r2_q1, r2_q2;
wire [19:0] r3_q1, r3_q2;
wire [19:0] r4_q1, r4_q2;
wire [19:0] c1_q1, c1_q2;
wire [19:0] c2_q1, c2_q2;
wire [19:0] c3_q1, c3_q2;
wire [19:0] c4_q1, c4_q2;

reg [3:0] mag_sq_input_number;
reg [19:0] mag_sq_q1;
reg [19:0] mag_sq_q2;
reg [12:0] mag_sq_coeff;

reg [39:0] p1, p2;
reg [51:0] p3;
reg [41:0] sum;
reg pressed;
reg r1_p, r2_p, r3_p, r4_p;
reg c1_p, c2_p, c3_p, c4_p;
reg evaluate;
reg [7:0] key, lastKey;

always @ (posedge clk)
begin
	if (rst)
	begin
		count <= 0;
		first <= 1;
		iir_outs_valid <= 0;
		r1_q1_r <= 0;
		r1_q2_r <= 0;
		r2_q1_r <= 0;
		r2_q2_r <= 0;
		r3_q1_r <= 0;
		r3_q2_r <= 0;
		r4_q1_r <= 0;
		r4_q2_r <= 0;
		c1_q1_r <= 0;
		c1_q2_r <= 0;
		c2_q1_r <= 0;
		c2_q2_r <= 0;
		c3_q1_r <= 0;
		c3_q2_r <= 0;
		c4_q1_r <= 0;
		c4_q2_r <= 0;
		mag_sq_input_number <= 0;
		mag_sq_q1 <= 0; 
		mag_sq_q2 <= 0; 
		mag_sq_coeff <= 0;
		p1 <= 0;
		p2 <= 0;
		p3 <= 0;
		sum <= 0;
		pressed <= 0;
		r1_p <= 0;
		r2_p <= 0;
		r3_p <= 0;
		r4_p <= 0;
		c1_p <= 0;
		c2_p <= 0;
		c3_p <= 0;
		c4_p <= 0;
		evaluate <= 0;
		newKey <= 0;
		key <= 0;
		theKey <= 0;
		lastKey <= 0;

		dtmf_valid <= 0;
		dtmf_data <= 0;
	end
	else
	begin
		if (valid) 
		begin
			if (count == 204)
			begin
				count <= 0;
				first <= 1;
			end
			else
			begin
				count <= count + 1;
				first <= 0;
			end
		end

		if (valid && first)
		begin
			iir_outs_valid <= 1;
			r1_q1_r <= r1_q1;
			r1_q2_r <= r1_q2;
			r2_q1_r <= r2_q1;
			r2_q2_r <= r2_q2;
			r3_q1_r <= r3_q1;
			r3_q2_r <= r3_q2;
			r4_q1_r <= r4_q1;
			r4_q2_r <= r4_q2;
			c1_q1_r <= c1_q1;
			c1_q2_r <= c1_q2;
			c2_q1_r <= c2_q1;
			c2_q2_r <= c2_q2;
			c3_q1_r <= c3_q1;
			c3_q2_r <= c3_q2;
			c4_q1_r <= c4_q1;
			c4_q2_r <= c4_q2;
		end
		else
		begin
			iir_outs_valid <= 0;
		end

		if (iir_outs_valid)
		begin
			mag_sq_input_number <= 0;
		end
		else if (mag_sq_input_number < 15)
		begin
			mag_sq_input_number <= mag_sq_input_number + 1;
		end

		case (mag_sq_input_number)
			0: begin mag_sq_q1 <= r1_q1_r; mag_sq_q2 <= r1_q2_r; mag_sq_coeff <= 3488; end
			1: begin mag_sq_q1 <= r2_q1_r; mag_sq_q2 <= r2_q2_r; mag_sq_coeff <= 3350; end
			2: begin mag_sq_q1 <= r3_q1_r; mag_sq_q2 <= r3_q2_r; mag_sq_coeff <= 3200; end
			3: begin mag_sq_q1 <= r4_q1_r; mag_sq_q2 <= r4_q2_r; mag_sq_coeff <= 3037; end
			4: begin mag_sq_q1 <= c1_q1_r; mag_sq_q2 <= c1_q2_r; mag_sq_coeff <= 2382; end
			5: begin mag_sq_q1 <= c2_q1_r; mag_sq_q2 <= c2_q2_r; mag_sq_coeff <= 2066; end
			6: begin mag_sq_q1 <= c3_q1_r; mag_sq_q2 <= c3_q2_r; mag_sq_coeff <= 1618; end
			7: begin mag_sq_q1 <= c4_q1_r; mag_sq_q2 <= c4_q2_r; mag_sq_coeff <= 1146; end
			default: begin mag_sq_q1 <= 0; mag_sq_q2 <= 0; end
		endcase

		// 9.11 * 9.11 = 18.22
		// 9.11 * 9.11 = 18.22
		// 9.11 * 9.11 * 1.11 = 19.33

		p1 <= $signed (mag_sq_q1) * $signed (mag_sq_q1);
		p2 <= $signed (mag_sq_q2) * $signed (mag_sq_q2);
		p3 <= $signed (mag_sq_q1) * $signed (mag_sq_q2) * $signed (mag_sq_coeff);

		sum <= { {2{p1[39]}}, p1[39:0] } + 
		       { {2{p2[39]}}, p2[39:0] } - 
			   { {1{p3[51]}}, p3[51:11] };

		pressed <= $signed(sum) > 419430400;

		if (mag_sq_input_number == 4) r1_p <= pressed;
		if (mag_sq_input_number == 5) r2_p <= pressed;
		if (mag_sq_input_number == 6) r3_p <= pressed;
		if (mag_sq_input_number == 7) r4_p <= pressed;
		if (mag_sq_input_number == 8) c1_p <= pressed;
		if (mag_sq_input_number == 9) c2_p <= pressed;
		if (mag_sq_input_number == 10) c3_p <= pressed;
		if (mag_sq_input_number == 11) c4_p <= pressed;
		evaluate <= (mag_sq_input_number == 12);
		if (evaluate) 
		begin
			     if (r1_p && c1_p) begin key <= "1"; dtmf_valid <= 1; dtmf_data <=  1; end
			else if (r1_p && c2_p) begin key <= "2"; dtmf_valid <= 1; dtmf_data <=  2; end
			else if (r1_p && c3_p) begin key <= "3"; dtmf_valid <= 1; dtmf_data <=  3; end
			else if (r1_p && c4_p) begin key <= "A"; dtmf_valid <= 1; dtmf_data <= 13; end
			else if (r2_p && c1_p) begin key <= "4"; dtmf_valid <= 1; dtmf_data <=  4; end
			else if (r2_p && c2_p) begin key <= "5"; dtmf_valid <= 1; dtmf_data <=  5; end
			else if (r2_p && c3_p) begin key <= "6"; dtmf_valid <= 1; dtmf_data <=  6; end
			else if (r2_p && c4_p) begin key <= "B"; dtmf_valid <= 1; dtmf_data <= 14; end
			else if (r3_p && c1_p) begin key <= "7"; dtmf_valid <= 1; dtmf_data <=  7; end
			else if (r3_p && c2_p) begin key <= "8"; dtmf_valid <= 1; dtmf_data <=  8; end
			else if (r3_p && c3_p) begin key <= "9"; dtmf_valid <= 1; dtmf_data <=  9; end
			else if (r3_p && c4_p) begin key <= "C"; dtmf_valid <= 1; dtmf_data <= 15; end
			else if (r4_p && c1_p) begin key <= "*"; dtmf_valid <= 1; dtmf_data <= 11; end
			else if (r4_p && c2_p) begin key <= "0"; dtmf_valid <= 1; dtmf_data <= 10; end
			else if (r4_p && c3_p) begin key <= "#"; dtmf_valid <= 1; dtmf_data <= 12; end
			else if (r4_p && c4_p) begin key <= "D"; dtmf_valid <= 1; dtmf_data <=  0; end
			else begin dtmf_valid <= 0; dtmf_data <= 0; end
		end

		newKey <= (key != lastKey);
		theKey <= key;
		lastKey <= key;
	end
end

// mag sq = q1 * q1 + q2 * q2 - q1 * q2 * coeff

dtmf_iir #(3488) dtmf_iir_r1_697_3488
(
	.clk		(clk),
	.rst		(rst),
	.valid		(valid),
	.first		(first),
	.data		(data),
	.q1			(r1_q1),
	.q2			(r1_q2)
);

dtmf_iir #(3350) dtmf_iir_r2_770_3350
(
	.clk		(clk),
	.rst		(rst),
	.valid		(valid),
	.first		(first),
	.data		(data),
	.q1			(r2_q1),
	.q2			(r2_q2)
);

dtmf_iir #(3200) dtmf_iir_r3_852_3200
(
	.clk		(clk),
	.rst		(rst),
	.valid		(valid),
	.first		(first),
	.data		(data),
	.q1			(r3_q1),
	.q2			(r3_q2)
);

dtmf_iir #(3037) dtmf_iir_r4_941_3037
(
	.clk		(clk),
	.rst		(rst),
	.valid		(valid),
	.first		(first),
	.data		(data),
	.q1			(r4_q1),
	.q2			(r4_q2)
);

dtmf_iir #(2382) dtmf_iir_c1_1209_2382
(
	.clk		(clk),
	.rst		(rst),
	.valid		(valid),
	.first		(first),
	.data		(data),
	.q1			(c1_q1),
	.q2			(c1_q2)
);

dtmf_iir #(2066) dtmf_iir_c2_1336_2066
(
	.clk		(clk),
	.rst		(rst),
	.valid		(valid),
	.first		(first),
	.data		(data),
	.q1			(c2_q1),
	.q2			(c2_q2)
);

dtmf_iir #(1618) dtmf_iir_c3_1477_1618
(
	.clk		(clk),
	.rst		(rst),
	.valid		(valid),
	.first		(first),
	.data		(data),
	.q1			(c3_q1),
	.q2			(c3_q2)
);

dtmf_iir #(1146) dtmf_iir_c4_1633_1146
(
	.clk		(clk),
	.rst		(rst),
	.valid		(valid),
	.first		(first),
	.data		(data),
	.q1			(c4_q1),
	.q2			(c4_q2)
);

endmodule

module dtmf_iir
(
	input	wire			clk,
	input	wire			rst,
	input	wire			valid,
	input	wire			first,
	input	wire	[11:0]	data,
	output	reg		[19:0]	q1,
	output	reg		[19:0]	q2
);

parameter coeff = 12'd3200;

// coeff * q1 - q2 + data
//
// coeff:           x.xxxx xxxx xxx	 12b
// q1:    s xxxx xxxx.xxxx xxxx xxx  20b
// q2:    s xxxx xxxx.xxxx xxxx xxx  20b
// data:            s.xxxx xxxx xxx  12b
//
// coeff * q1: Ssx xxxx xxxx.xxxx xxxx xxxx xxxx xxxx xx
//         q2: SSs xxxx xxxx.xxxx xxxx xxx0 0000 0000 00
//       data: SSS SSSS SSSs.xxxx xxxx xxx0 0000 0000 00
//     result: sxx xxxx xxxx.xxxx xxxx xxxx xxxx xxxx xx
//      round:                            1 0000 0000 00
//      final:   s xxxx xxxx.xxxx xxxx xxx
//     

wire [32:0] term_pre0 = $signed ( {1'b0,coeff} ) * $signed (q1);
wire [32:0] term_pre1 = term_pre0 - 
						{ {2{q2[19]}}, q2[19:0], 11'b0 } + 
						{ {10{data[11]}}, data[11:0], 11'b0 } +
						11'b1_0000_0000_00;
wire [19:0] term_pre2 =  (term_pre1[32]) ? 
        ((&term_pre1[31:30]) ? (term_pre1[30:11]) : (20'h80000)) :
        ((|term_pre1[31:30]) ? (20'h7ffff) : (term_pre1[30:11])) ;

wire [19:0] next_q1 = first ? { {8{data[11]}}, data[11:0] } : term_pre2;
						

wire [19:0] next_q2 = first ? 20'b0 : q1;


always @ (posedge clk)
begin
	if (rst)
	begin
		q1 <= 0;
		q2 <= 0;
	end
	else
	begin
		if (valid) 
		begin
			q1 <= next_q1;
			q2 <= next_q2;
		end
	end
end

endmodule
