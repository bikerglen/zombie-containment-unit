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
 * dmx.c
 *
 *  Created on: Sep 9, 2017
 *      Author: glen
 */

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include "xparameters.h"
#include "xil_io.h"

#include "zcu.h"
#include "dmx.h"

uint8_t dmx0_tx_buffer[DMX_UNI_0_NUM_CHANS];

void dmx_Init (void)
{
	dmx_ClearBuffer ();
	dmx_Transmit ();
}


void dmx_ClearBuffer (void)
{
	for (int i = 0; i < DMX_UNI_0_NUM_CHANS; i++) {
		dmx0_tx_buffer[i] = 0x00;
	}
}


void dmx_Transmit (void)
{
	int i;

	// send break, mark after break, 0x00 control code
	Xil_Out32 (ZCU_DMX_TX_UNIVERSE_0, 0x100);
	Xil_Out32 (ZCU_DMX_TX_UNIVERSE_0, 0x00);

	// send dmx channels
	for (i = 0; i < DMX_UNI_0_NUM_CHANS; i++) {
		Xil_Out32 (ZCU_DMX_TX_UNIVERSE_0, dmx0_tx_buffer[i]);
	}
}
