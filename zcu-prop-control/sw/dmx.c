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
	int i;

	for (i = 0; i < DMX_UNI_0_NUM_CHANS; i++) {
		dmx0_tx_buffer[i] = 0xff;
	}

	dmx_Transmit ();
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
