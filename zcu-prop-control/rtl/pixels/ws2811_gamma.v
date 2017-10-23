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

// gamma correction 
// curve stolen from https://learn.adafruit.com/led-tricks-gamma-correction/the-longer-fix
module ws2811_gamma
(
	input	wire	[7:0]	din,
	output	reg		[7:0]	dout
);

always @ (*)
begin
	case (din)
		  0: dout <=     0;   1: dout <=     0;   2: dout <=     0;   3: dout <=     0;
		  4: dout <=     0;   5: dout <=     0;   6: dout <=     0;   7: dout <=     0;
		  8: dout <=     0;   9: dout <=     0;  10: dout <=     0;  11: dout <=     0;
		 12: dout <=     0;  13: dout <=     0;  14: dout <=     0;  15: dout <=     0;
		 16: dout <=     0;  17: dout <=     0;  18: dout <=     0;  19: dout <=     0;
		 20: dout <=     0;  21: dout <=     0;  22: dout <=     0;  23: dout <=     0;
		 24: dout <=     0;  25: dout <=     0;  26: dout <=     0;  27: dout <=     0;
		 28: dout <=     1;  29: dout <=     1;  30: dout <=     1;  31: dout <=     1;
		 32: dout <=     1;  33: dout <=     1;  34: dout <=     1;  35: dout <=     1;
		 36: dout <=     1;  37: dout <=     1;  38: dout <=     1;  39: dout <=     1;
		 40: dout <=     1;  41: dout <=     2;  42: dout <=     2;  43: dout <=     2;
		 44: dout <=     2;  45: dout <=     2;  46: dout <=     2;  47: dout <=     2;
		 48: dout <=     2;  49: dout <=     3;  50: dout <=     3;  51: dout <=     3;
		 52: dout <=     3;  53: dout <=     3;  54: dout <=     3;  55: dout <=     3;
		 56: dout <=     4;  57: dout <=     4;  58: dout <=     4;  59: dout <=     4;
		 60: dout <=     4;  61: dout <=     5;  62: dout <=     5;  63: dout <=     5;
		 64: dout <=     5;  65: dout <=     6;  66: dout <=     6;  67: dout <=     6;
		 68: dout <=     6;  69: dout <=     7;  70: dout <=     7;  71: dout <=     7;
		 72: dout <=     7;  73: dout <=     8;  74: dout <=     8;  75: dout <=     8;
		 76: dout <=     9;  77: dout <=     9;  78: dout <=     9;  79: dout <=    10;
		 80: dout <=    10;  81: dout <=    10;  82: dout <=    11;  83: dout <=    11;
		 84: dout <=    11;  85: dout <=    12;  86: dout <=    12;  87: dout <=    13;
		 88: dout <=    13;  89: dout <=    13;  90: dout <=    14;  91: dout <=    14;
		 92: dout <=    15;  93: dout <=    15;  94: dout <=    16;  95: dout <=    16;
		 96: dout <=    17;  97: dout <=    17;  98: dout <=    18;  99: dout <=    18;
		100: dout <=    19; 101: dout <=    19; 102: dout <=    20; 103: dout <=    20;
		104: dout <=    21; 105: dout <=    21; 106: dout <=    22; 107: dout <=    22;
		108: dout <=    23; 109: dout <=    24; 110: dout <=    24; 111: dout <=    25;
		112: dout <=    25; 113: dout <=    26; 114: dout <=    27; 115: dout <=    27;
		116: dout <=    28; 117: dout <=    29; 118: dout <=    29; 119: dout <=    30;
		120: dout <=    31; 121: dout <=    32; 122: dout <=    32; 123: dout <=    33;
		124: dout <=    34; 125: dout <=    35; 126: dout <=    35; 127: dout <=    36;
		128: dout <=    37; 129: dout <=    38; 130: dout <=    39; 131: dout <=    39;
		132: dout <=    40; 133: dout <=    41; 134: dout <=    42; 135: dout <=    43;
		136: dout <=    44; 137: dout <=    45; 138: dout <=    46; 139: dout <=    47;
		140: dout <=    48; 141: dout <=    49; 142: dout <=    50; 143: dout <=    50;
		144: dout <=    51; 145: dout <=    52; 146: dout <=    54; 147: dout <=    55;
		148: dout <=    56; 149: dout <=    57; 150: dout <=    58; 151: dout <=    59;
		152: dout <=    60; 153: dout <=    61; 154: dout <=    62; 155: dout <=    63;
		156: dout <=    64; 157: dout <=    66; 158: dout <=    67; 159: dout <=    68;
		160: dout <=    69; 161: dout <=    70; 162: dout <=    72; 163: dout <=    73;
		164: dout <=    74; 165: dout <=    75; 166: dout <=    77; 167: dout <=    78;
		168: dout <=    79; 169: dout <=    81; 170: dout <=    82; 171: dout <=    83;
		172: dout <=    85; 173: dout <=    86; 174: dout <=    87; 175: dout <=    89;
		176: dout <=    90; 177: dout <=    92; 178: dout <=    93; 179: dout <=    95;
		180: dout <=    96; 181: dout <=    98; 182: dout <=    99; 183: dout <=   101;
		184: dout <=   102; 185: dout <=   104; 186: dout <=   105; 187: dout <=   107;
		188: dout <=   109; 189: dout <=   110; 190: dout <=   112; 191: dout <=   114;
		192: dout <=   115; 193: dout <=   117; 194: dout <=   119; 195: dout <=   120;
		196: dout <=   122; 197: dout <=   124; 198: dout <=   126; 199: dout <=   127;
		200: dout <=   129; 201: dout <=   131; 202: dout <=   133; 203: dout <=   135;
		204: dout <=   137; 205: dout <=   138; 206: dout <=   140; 207: dout <=   142;
		208: dout <=   144; 209: dout <=   146; 210: dout <=   148; 211: dout <=   150;
		212: dout <=   152; 213: dout <=   154; 214: dout <=   156; 215: dout <=   158;
		216: dout <=   160; 217: dout <=   162; 218: dout <=   164; 219: dout <=   167;
		220: dout <=   169; 221: dout <=   171; 222: dout <=   173; 223: dout <=   175;
		224: dout <=   177; 225: dout <=   180; 226: dout <=   182; 227: dout <=   184;
		228: dout <=   186; 229: dout <=   189; 230: dout <=   191; 231: dout <=   193;
		232: dout <=   196; 233: dout <=   198; 234: dout <=   200; 235: dout <=   203;
		236: dout <=   205; 237: dout <=   208; 238: dout <=   210; 239: dout <=   213;
		240: dout <=   215; 241: dout <=   218; 242: dout <=   220; 243: dout <=   223;
		244: dout <=   225; 245: dout <=   228; 246: dout <=   231; 247: dout <=   233;
		248: dout <=   236; 249: dout <=   239; 250: dout <=   241; 251: dout <=   244;
		252: dout <=   247; 253: dout <=   249; 254: dout <=   252; 255: dout <=   255;
	endcase
end

endmodule
