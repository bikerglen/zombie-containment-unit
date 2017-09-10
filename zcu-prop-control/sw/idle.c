/*
 * idle.c
 *
 *  Created on: Feb 22, 2017
 *      Author: glen
 */

#include <stdio.h>
#include <stdlib.h>
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
#include "levelbg.h"
#include "fieldbg.h"
#include "idle.h"

static int clusterLampTimer;
static int clusterLampState;

static int activityGraphTimer;

void idle_Init (void)
{
	print ("IDLE\n\r");

	// reset elapsed time timer
	Xil_Out32 (ZCU_ELAPSED_TIME, 0x1);

	// set cluster pilot light to blue
	clusterLampTimer = 0;
	clusterLampState = 1;
	Xil_Out32 (ZCU_LIGHTS, (Xil_In32 (ZCU_LIGHTS) & ~ZCU_CLUSTER_PILOT_LIGHT_MASK) | ZCU_CLUSTER_PILOT_LIGHT_BLUE);

	// turn off danger and purge lights
	Xil_Out32 (ZCU_LIGHTS, Xil_In32 (ZCU_LIGHTS) & ~ZCU_DANGER_LIGHT);
	Xil_Out32 (ZCU_LIGHTS, Xil_In32 (ZCU_LIGHTS) & ~ZCU_PURGE_LIGHT);

	// turn on amber side lights
	Xil_Out32 (ZCU_LIGHTS, Xil_In32 (ZCU_LIGHTS) | ZCU_RIGHT_LIGHT);
	Xil_Out32 (ZCU_LIGHTS, Xil_In32 (ZCU_LIGHTS) | ZCU_LEFT_LIGHT);

	// set first two bar graphs to no decode mode, rest to decode digits mode
	bargraph_NoDecodeDigits (0);
	bargraph_NoDecodeDigits (1);
	bargraph_DecodeDigits (2);
	bargraph_DecodeDigits (3);

	// spin digits on virus levels numeric display
	bargraph_SpinDigitsInit (0b0001);

	// low-level + noise on virus levels bar graph display
	levelGraph_SetGains (0.125, 0.125);
	levelGraph_SetNoiseGainOffset (2.0, 1.0);
	levelGraph_SetTarget (3.5);

	// random blips on squiggle bar graph
	activityGraphTimer = 0;
	bargraph_SetDotFromLeft (1, 0);

	// low oscillating levels on the two containment field bar graphs and numeric displays
	leftcf_SetUserTarget (4.1);
	leftcf_Tick ();
	rightcf_SetUserTarget (4.1);
	rightcf_Tick ();
}


void idle_QuickTasks (void)
{
	int key;

	// echo DTMF tones to screen, could also do tasks that depend on tones here
	if (Xil_In32 (ZCU_DTMF_KEY_FLAG) & 0x1) {
		key = Xil_In32 (ZCU_DTMF_KEY_DATA);
		xil_printf ("DTMF: %c\n\r", key);
	}
}


void idle_TickTasks (void)
{
	int dot;

	// blink cluster pilot light blue light
	clusterLampTimer++;
	if (clusterLampTimer >= 25) {
		clusterLampTimer = 0;
		clusterLampState = (clusterLampState + 1) & 0x1;
		Xil_Out32 (ZCU_LIGHTS, (Xil_In32 (ZCU_LIGHTS) & ~ZCU_CLUSTER_PILOT_LIGHT_MASK) | (clusterLampState ? ZCU_CLUSTER_PILOT_LIGHT_BLUE : ZCU_CLUSTER_PILOT_LIGHT_OFF));
	}

	// spin digits on virus levels bar graph
	bargraph_SpinDigitsTick (0b0001);

	// low-level + noise on virus levels bar graph display
	levelGraph_Tick ();

	// random blips on squiggle bar graph
	activityGraphTimer++;
	if (activityGraphTimer >= 33) {
		activityGraphTimer = 0;
		dot = ((float)rand())/((float)RAND_MAX) * 32.0 + 1;
		bargraph_SetDotFromLeft (1, dot);
	}

	// low oscillating levels on the two containment field bar graphs and numeric displays
	leftcf_Tick ();
	rightcf_Tick ();

	// update dmx levels
	sine_Tick ();
	sine_MapToDmx ();

	// transmit dmx levels
	dmx_Transmit ();
}
