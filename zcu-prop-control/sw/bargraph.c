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

/*
 * bargraph.c
 *
 *  Created on: Feb 22, 2017
 *      Author: glen
 */

#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xstatus.h"
#include "xiic.h"
#include "xil_printf.h"
#include "xil_io.h"

#include "zcu.h"
#include "bargraph.h"

// bargraph 0: virus levels: 24 segments + 3 digit display
// bargraph 1: virus activity: 32 segments + no digits
// bargraph 2: left containment field: 18 segments + 3 digit display + reverse order
// bargraph 3: right containment field: 18 segments + 3 digit display

static void bargraph_SpinDigitsUpdate (uint8_t mask);

static const uint8_t dot_decode_table[9] = {
	0x00, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01, 0x80
};

static const uint8_t dot_decode_table_rev[9] = {
	0x00, 0x80, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40
};

static const uint8_t bar_decode_table[9] = {
	0x00, 0x40, 0x60, 0x70, 0x78, 0x7C, 0x7E, 0x7F, 0xFF
};

static const uint8_t bar_decode_table_rev[9] = {
	0x00, 0x80, 0x81, 0x83, 0x87, 0x8F, 0x9F, 0xBF, 0xFF
};

static const uint8_t dot_decode_table_18[7] = {
	0x00, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02
};

static const uint8_t dot_decode_table_rev_18[7] = {
	0x00, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40
};

static const uint8_t bar_decode_table_18[7] = {
	0x00, 0x40, 0x60, 0x70, 0x78, 0x7C, 0x7E
};

static const uint8_t bar_decode_table_rev_18[7] = {
	0x00, 0x02, 0x06, 0x0E, 0x1E, 0x3E, 0x7E
};

static const uint8_t spinDigitsPattern[30] = {
	0x00, 0x00, 0x40,
	0x40, 0x00, 0x00,
	0x00, 0x40, 0x00,
	0x00, 0x20, 0x00,
	0x00, 0x10, 0x00,
	0x00, 0x08, 0x00,
	0x08, 0x00, 0x00,
	0x00, 0x00, 0x08,
	0x00, 0x00, 0x04,
	0x00, 0x00, 0x02
};


static int spinDigitsTimer;
static int spinDigitsState;


void bargraph_SpiInit (void)
{
	Xil_Out32 (XPAR_SPI_0_BASEADDR + 0x60, 0x86);
}


void bargraph_SpiWrite (uint8_t which, uint8_t addr, uint8_t data)
{
	uint16_t chip_selects;

	chip_selects = 0xFFFF & ~(1 << which);
	Xil_Out32 (XPAR_SPI_0_BASEADDR + 0x70, chip_selects);

	Xil_Out32 (XPAR_SPI_0_BASEADDR + 0x68, addr);
	while (Xil_In32 (XPAR_SPI_0_BASEADDR + 0x64) & 0x8) {
	}

	Xil_Out32 (XPAR_SPI_0_BASEADDR + 0x68, data);
	while (Xil_In32 (XPAR_SPI_0_BASEADDR + 0x64) & 0x8) {
	}

	Xil_Out32 (XPAR_SPI_0_BASEADDR + 0x70, 0xFFFF);
}


void bargraph_Init (uint8_t which)
{
	int i;

	// clear segments, set digits to 000
	for (i = 0; i < 4; i++) {
		bargraph_SpiWrite (which, 0x60 + i, 0x00);
	}

	bargraph_SpiWrite (which, 0x01, 0xf0); // decode mode -- decode 7:4, no decode 3:0
	bargraph_SpiWrite (which, 0x02, 0x00); // global intensity -- minimum
	bargraph_SpiWrite (which, 0x03, 0x07); // scan limit -- display 16 7 segment digits
	bargraph_SpiWrite (which, 0x04, 0x41); // configuration -- enable w/ individual intensity
	bargraph_SpiWrite (which, 0x05, 0x00); // gpio data
	bargraph_SpiWrite (which, 0x06, 0x00); // port configuration
	bargraph_SpiWrite (which, 0x07, 0x00); // display test -- off
	bargraph_SpiWrite (which, 0x0C, 0x00); // digit type -- all 7 or 16 segment displays

	bargraph_SpiWrite (which, 0x10, 0x00); // intensity 10 -- unused
	bargraph_SpiWrite (which, 0x11, 0x00); // intensity 32 -- unused
	bargraph_SpiWrite (which, 0x12, 0x00); // intensity 54 -- unused
	bargraph_SpiWrite (which, 0x13, 0x00); // intensity 76 -- unused
	bargraph_SpiWrite (which, 0x14, 0xbb); // intensity 10a -- bar graph segments a little dimmer
	bargraph_SpiWrite (which, 0x15, 0xbb); // intensity 32a -- bar graph segments a little dimmer
	bargraph_SpiWrite (which, 0x16, 0xff); // intensity 54a -- bar graph digits full intensity
	bargraph_SpiWrite (which, 0x17, 0xff); // intensity 76a -- bar graph digits full intensity
}


void bargraph_NoDecodeDigits (uint8_t which)
{
	int i;

	// disable display
	// bargraph_SpiWrite (which, 0x04, 0x40); // configuration -- disable

	// set decode mode
	bargraph_SpiWrite (which, 0x01, 0x00); // decode mode -- no decode 7:0

	// clear digits
	for (i = 0; i < 4; i++) {
		bargraph_SpiWrite (which, 0x64 + i, 0x00);
		bargraph_SpiWrite (which, 0x6C + i, 0x00);
	}

	// enable display
	// bargraph_SpiWrite (which, 0x04, 0x41); // configuration -- enable w/ individual intensity
}


void bargraph_DecodeDigits (uint8_t which)
{
	int i;

	// disable display
	// bargraph_SpiWrite (which, 0x04, 0x40); // configuration -- disable

	// set decode mode
	bargraph_SpiWrite (which, 0x01, 0xf0); // decode mode -- decode 7:4, no decode 3:0

	// clear digits
	for (i = 0; i < 4; i++) {
		bargraph_SpiWrite (which, 0x64 + i, 0x00);
		// bargraph_SpiWrite (which, 0x6C + i, 0x00);
	}

	// clear segments, set digits to 000
	// for (i = 0; i < 4; i++) {
	// bargraph_SpiWrite (which, 0x60 + i, 0x00);
	// }
	// for (; i < 8; i++) {
	// bargraph_SpiWrite (which, 0x60 + i, 0x00);
	// }
	// for (; i < 12; i++) {
	// bargraph_SpiWrite (which, 0x60 + i, 0x00);
	// }
	// for (; i < 16; i++) {
	// bargraph_SpiWrite (which, 0x60 + i, 0x20);
	// }

	// enable display
	// bargraph_SpiWrite (which, 0x04, 0x41); // configuration -- enable w/ individual intensity
}


void bargraph_SetDotFromLeft (uint8_t which, uint8_t dot)
{
	uint8_t a = 0, b = 0, c = 0, d = 0;

	if (dot < 1) {
	} else if (dot < 9) {
		a = dot_decode_table[dot-0];
	} else if (dot < 17) {
		b = dot_decode_table[dot-8];
	} else if (dot < 25) {
		c = dot_decode_table[dot-16];
	} else if (dot < 33) {
		d = dot_decode_table[dot-24];
	}

	bargraph_SpiWrite (which, 0x68, a);
	bargraph_SpiWrite (which, 0x69, b);
	bargraph_SpiWrite (which, 0x6a, c);
	bargraph_SpiWrite (which, 0x6b, d);
}


void bargraph_SetDotFromRight (uint8_t which, uint8_t dot)
{
	uint8_t a = 0, b = 0, c = 0, d = 0;

	if (dot < 1) {
	} else if (dot < 9) {
		d = dot_decode_table_rev[dot-0];
	} else if (dot < 17) {
		c = dot_decode_table_rev[dot-8];
	} else if (dot < 25) {
		b = dot_decode_table_rev[dot-16];
	} else if (dot < 33) {
		a = dot_decode_table_rev[dot-24];
	}

	bargraph_SpiWrite (which, 0x68, a);
	bargraph_SpiWrite (which, 0x69, b);
	bargraph_SpiWrite (which, 0x6a, c);
	bargraph_SpiWrite (which, 0x6b, d);
}


void bargraph_SetBarFromLeft (uint8_t which, uint8_t n)
{
	uint8_t a = 0, b = 0, c = 0, d = 0;

	if (n < 1) {
	} else if (n < 9) {
		a = bar_decode_table[n-0];
	} else if (n < 17) {
		a = 0xff;
		b = bar_decode_table[n-8];
	} else if (n < 25) {
		a = 0xff;
		b = 0xff;
		c = bar_decode_table[n-16];
	} else if (n < 33) {
		a = 0xff;
		b = 0xff;
		c = 0xff;
		d = bar_decode_table[n-24];
	}

	bargraph_SpiWrite (which, 0x68, a);
	bargraph_SpiWrite (which, 0x69, b);
	bargraph_SpiWrite (which, 0x6a, c);
	bargraph_SpiWrite (which, 0x6b, d);
}

// TODO -- void bargraph_SetBarFromRight (uint8_t which, uint8_t dot);

void bargraph_SetDotFromLeft18 (uint8_t which, uint8_t dot)
{
	uint8_t a = 0, b = 0, c = 0, d = 0;

	if (dot < 1) {
	} else if (dot < 7) {
		a = dot_decode_table_18[dot-0];
	} else if (dot < 13) {
		b = dot_decode_table_18[dot-6];
	} else if (dot < 19) {
		c = dot_decode_table_18[dot-12];
	}

	bargraph_SpiWrite (which, 0x68, a);
	bargraph_SpiWrite (which, 0x69, b);
	bargraph_SpiWrite (which, 0x6a, c);
	bargraph_SpiWrite (which, 0x6b, d);
}


void bargraph_SetDotFromRight18 (uint8_t which, uint8_t dot)
{
	uint8_t a = 0, b = 0, c = 0, d = 0;

	if (dot < 1) {
	} else if (dot < 7) {
		c = dot_decode_table_rev_18[dot-0];
	} else if (dot < 13) {
		b = dot_decode_table_rev_18[dot-6];
	} else if (dot < 19) {
		a = dot_decode_table_rev_18[dot-12];
	}

	bargraph_SpiWrite (which, 0x68, a);
	bargraph_SpiWrite (which, 0x69, b);
	bargraph_SpiWrite (which, 0x6a, c);
	bargraph_SpiWrite (which, 0x6b, d);
}


void bargraph_SetBarFromLeft18 (uint8_t which, uint8_t n)
{
	uint8_t a = 0, b = 0, c = 0, d = 0;

	if (n < 1) {
	} else if (n < 7) {
		a = bar_decode_table_18[n-0];
	} else if (n < 13) {
		a = 0x7e;
		b = bar_decode_table_18[n-6];
	} else if (n < 19) {
		a = 0x7e;
		b = 0x7e;
		c = bar_decode_table_18[n-12];
	}

	bargraph_SpiWrite (which, 0x68, a);
	bargraph_SpiWrite (which, 0x69, b);
	bargraph_SpiWrite (which, 0x6a, c);
	bargraph_SpiWrite (which, 0x6b, d);
}


void bargraph_SetBarFromRight18 (uint8_t which, uint8_t n)
{
	uint8_t a = 0, b = 0, c = 0, d = 0;

	if (n < 1) {
	} else if (n < 7) {
		c = bar_decode_table_rev_18[n-0];
	} else if (n < 13) {
		c = 0x7e;
		b = bar_decode_table_rev_18[n-6];
	} else if (n < 19) {
		c = 0x7e;
		b = 0x7e;
		a = bar_decode_table_rev_18[n-12];
	}

	bargraph_SpiWrite (which, 0x68, a);
	bargraph_SpiWrite (which, 0x69, b);
	bargraph_SpiWrite (which, 0x6a, c);
	bargraph_SpiWrite (which, 0x6b, d);
}


void bargraph_SpinDigitsInit (uint8_t mask)
{
	spinDigitsTimer = 0;
	spinDigitsState = 0;
	bargraph_SpinDigitsUpdate (mask);
}


void bargraph_SpinDigitsTick (uint8_t mask)
{
	spinDigitsTimer++;
	if (spinDigitsTimer >= 5) {
		spinDigitsTimer = 0;
		spinDigitsState++;
		if (spinDigitsState >= 10) {
			spinDigitsState = 0;
		}
		bargraph_SpinDigitsUpdate (mask);
	}
}


static void bargraph_SpinDigitsUpdate (uint8_t mask)
{
	uint8_t a, b, c;

	a = spinDigitsPattern[3*spinDigitsState+0];
	b = spinDigitsPattern[3*spinDigitsState+1];
	c = spinDigitsPattern[3*spinDigitsState+2];

	if (mask & 1) {
		bargraph_SpiWrite (0, 0x6c, a);
		bargraph_SpiWrite (0, 0x6d, b);
		bargraph_SpiWrite (0, 0x6e, c);
	}
	if (mask & 2) {
		bargraph_SpiWrite (1, 0x6c, a);
		bargraph_SpiWrite (1, 0x6d, b);
		bargraph_SpiWrite (1, 0x6e, c);
	}
	if (mask & 4) {
		bargraph_SpiWrite (2, 0x6c, a);
		bargraph_SpiWrite (2, 0x6d, b);
		bargraph_SpiWrite (2, 0x6e, c);
	}
	if (mask & 8) {
		bargraph_SpiWrite (3, 0x6c, a);
		bargraph_SpiWrite (3, 0x6d, b);
		bargraph_SpiWrite (3, 0x6e, c);
	}
}


void bargraph_SetDigits (uint8_t select, uint8_t dp, uint16_t n)
{
	unsigned char SPACE = 0x10;
	unsigned char DP = 0x80;
	unsigned short h = n / 100;
	unsigned short t = (n - h * 100) / 10;
	unsigned short o = (n - h * 100 - t * 10);

	if (dp == 0) {
		bargraph_SpiWrite (select, 0x6e, (h == 0) ? SPACE : h);
		bargraph_SpiWrite (select, 0x6c, ((h == 0) && (t == 0)) ? SPACE : t);
		bargraph_SpiWrite (select, 0x6d, o);
	} else if (dp == 1) {
		bargraph_SpiWrite (select, 0x6e, (h == 0) ? SPACE : h);
		bargraph_SpiWrite (select, 0x6c, DP | t);
		bargraph_SpiWrite (select, 0x6d, o);
	} else if (dp == 2) {
		bargraph_SpiWrite (select, 0x6e, DP | h);
		bargraph_SpiWrite (select, 0x6c, t);
		bargraph_SpiWrite (select, 0x6d, o);
	}
}


void bargraph_SetRange32 (uint8_t select, int first, int last)
{
	uint8_t a = 0, b = 0, c = 0, d = 0;
	int dot;

	if (last > 32) {
		for (dot = first; dot <= 32; dot++) {
			if (dot < 1) {
			} else if (dot < 9) {
				a |= dot_decode_table[dot-0];
			} else if (dot < 17) {
				b |= dot_decode_table[dot-8];
			} else if (dot < 25) {
				c |= dot_decode_table[dot-16];
			} else if (dot < 33) {
				d |= dot_decode_table[dot-24];
			}
		}
		for (dot = 1; dot <= (last-32); dot++) {
			if (dot < 1) {
			} else if (dot < 9) {
				a |= dot_decode_table[dot-0];
			} else if (dot < 17) {
				b |= dot_decode_table[dot-8];
			} else if (dot < 25) {
				c |= dot_decode_table[dot-16];
			} else if (dot < 33) {
				d |= dot_decode_table[dot-24];
			}
		}
	} else {
		for (dot = first; dot <= last; dot++) {
			if (dot < 1) {
			} else if (dot < 9) {
				a |= dot_decode_table[dot-0];
			} else if (dot < 17) {
				b |= dot_decode_table[dot-8];
			} else if (dot < 25) {
				c |= dot_decode_table[dot-16];
			} else if (dot < 33) {
				d |= dot_decode_table[dot-24];
			}
		}
	}
	bargraph_SpiWrite (select, 0x68, a);
	bargraph_SpiWrite (select, 0x69, b);
	bargraph_SpiWrite (select, 0x6a, c);
	bargraph_SpiWrite (select, 0x6b, d);
}
