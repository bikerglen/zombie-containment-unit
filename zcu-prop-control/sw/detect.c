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
 * detect.c
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
#include "dmx.h"
#include "sine.h"
#include "bargraph.h"
#include "detect.h"

static int clusterPilotLightDelayTimer;
static int clusterPilotLightSpinValue;

static int barSegmentsDelayTimer;
static int barSegmentsSpinState;

static int lampTimer;
static int lampState;

static void detect_UpdateBarGraphs (void);

void detect_Init (void)
{
	print ("DETECT\n\r");

	// reset elapsed time timer
	Xil_Out32 (ZCU_ELAPSED_TIME, 0x1);

	// initialize cluster pilot light spin
	clusterPilotLightDelayTimer = 0;
	clusterPilotLightSpinValue = 0;
	Xil_Out32 (ZCU_LIGHTS, (Xil_In32 (ZCU_LIGHTS) & ~ZCU_CLUSTER_PILOT_LIGHT_MASK) | (1 << clusterPilotLightSpinValue));

	// set all bar graphs to no decode mode
	bargraph_NoDecodeDigits (0);
	bargraph_NoDecodeDigits (1);
	bargraph_NoDecodeDigits (2);
	bargraph_NoDecodeDigits (3);

	// spin 7 segment displays in a circle, spin leds on graphs
	bargraph_SpinDigitsInit (0b1101);

	// spin all bar graph segments
	barSegmentsDelayTimer = 0;
	barSegmentsSpinState = 0;
	detect_UpdateBarGraphs ();

	// init blink danger and purge lights
	lampTimer = 0;
	lampState = 0;

	// clear any left-over levels in dmx buffer
	dmx_ClearBuffer ();
}


void detect_QuickTasks (void)
{
	int key;

	// echo DTMF tones to screen, could also do tasks that depend on tones here
	if (Xil_In32 (ZCU_DTMF_KEY_FLAG) & 0x1) {
		key = Xil_In32 (ZCU_DTMF_KEY_DATA);
		xil_printf ("DTMF: %c\n\r", key);
	}
}


void detect_TickTasks (void)
{
	// spin cluster pilot light
	clusterPilotLightDelayTimer++;
	if (clusterPilotLightDelayTimer >= 5) {
		clusterPilotLightDelayTimer = 0;
		clusterPilotLightSpinValue = (clusterPilotLightSpinValue + 1) & 0x3;
		Xil_Out32 (ZCU_LIGHTS, (Xil_In32 (ZCU_LIGHTS) & ~ZCU_CLUSTER_PILOT_LIGHT_MASK) | (1 << clusterPilotLightSpinValue));
	}

	// spin seven segment displays
	bargraph_SpinDigitsTick (0b1101);

	// spin all bar graph segments
	// this exceeds the # of segments on many of the bar graphs but that's ok
	barSegmentsDelayTimer++;
	if (barSegmentsDelayTimer >= 3) {
		barSegmentsDelayTimer = 0;
		barSegmentsSpinState = (barSegmentsSpinState + 1) & 0x1f;
		detect_UpdateBarGraphs ();
	}

	// blink danger and purge lights
	lampTimer++;
	if (lampTimer >= 25) {
		lampTimer = 0;
		lampState = (lampState + 1) & 0x1;
		Xil_Out32 (ZCU_LIGHTS, (Xil_In32 (ZCU_LIGHTS) & ~0xF0) | (lampState ? 0xF0 : 0x00));
	}

	// update dmx levels
	sine_Tick ();
	sine_MapToDmx ();

	// transmit dmx levels
	dmx_Transmit ();
}


static void detect_UpdateBarGraphs (void)
{
	bargraph_SetDotFromLeft  (0, barSegmentsSpinState + 1);
	bargraph_SetDotFromLeft  (1, barSegmentsSpinState + 1);
	bargraph_SetDotFromRight18 (2, barSegmentsSpinState + 1);
	bargraph_SetDotFromLeft18  (3, barSegmentsSpinState + 1);
}
