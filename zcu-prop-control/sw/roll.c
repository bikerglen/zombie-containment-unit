/*
 * roll.c
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

#include "roll.h"
#include "bargraph.h"
#include "fieldbg.h"
#include "levelbg.h"
#include "zcu.h"
#include "dmx.h"
#include "sine.h"

static void roll_SetClusterLightToAmber (void);
static void roll_BlinkDangerLight (void);
static void roll_SetClusterLightToRed (void);
static void roll_Depressurize (void);
static void roll_BlinkPurgeLight (void);
static void roll_IncreaseActivity (void);

#define NUM_CUES 14

Cue cues[] = {
	{  5000, roll_IncreaseActivity },
	{ 10000, roll_IncreaseActivity },
	{ 15000, roll_IncreaseActivity },
	{ 20000, roll_IncreaseActivity },
	{ 25000, roll_IncreaseActivity },
	{ 30000, roll_IncreaseActivity },
	{ 35000, roll_IncreaseActivity },
	{ 40000, roll_IncreaseActivity },
	{ 45000, roll_IncreaseActivity },
	{ 54000, roll_SetClusterLightToAmber },
	{ 54000, roll_BlinkDangerLight },
	{ 64000, roll_SetClusterLightToRed },
	{ 64000, roll_Depressurize },
	{ 64000, roll_BlinkPurgeLight },
	{ 0, NULL }
};

static int cue;
static int rising;
static int falling;
static int dangerLightBlinkEnable;
static int dangerLightBlinkTimer;
static int dangerLightBlinkState;
static int purgeLightBlinkEnable;
static int purgeLightBlinkTimer;
static int purgeLightBlinkState;
static int activityGraphTimer;
static int activityGraphState;
static int activityGraphCounter;
static int activityGraphActivity;
static int redAlert;


void roll_Init (void)
{
	print ("ROLL\n\r");

	// reset elapsed time timer
	Xil_Out32 (ZCU_ELAPSED_TIME, 0x1);

	// set cluster pilot light to green
	Xil_Out32 (ZCU_LIGHTS, (Xil_In32 (ZCU_LIGHTS) & ~ZCU_CLUSTER_PILOT_LIGHT_MASK) | ZCU_CLUSTER_PILOT_LIGHT_GREEN);

	// turn off danger and purge lights, disable blinking
	dangerLightBlinkEnable = FALSE;
	dangerLightBlinkTimer = 0;
	dangerLightBlinkState = 1; // to cause immediate turn on once blink is enabled
	purgeLightBlinkEnable = FALSE;
	purgeLightBlinkTimer = 0;
	purgeLightBlinkState = 1; // to cause immediate turn on once blink is enabled
	Xil_Out32 (ZCU_LIGHTS, Xil_In32 (ZCU_LIGHTS) & ~ZCU_DANGER_LIGHT);
	Xil_Out32 (ZCU_LIGHTS, Xil_In32 (ZCU_LIGHTS) & ~ZCU_PURGE_LIGHT);

	// turn on amber side lights
	Xil_Out32 (ZCU_LIGHTS, Xil_In32 (ZCU_LIGHTS) | ZCU_RIGHT_LIGHT);
	Xil_Out32 (ZCU_LIGHTS, Xil_In32 (ZCU_LIGHTS) | ZCU_LEFT_LIGHT);

	// all bar graph displays to decode digits except for squiggle which has no digits
	bargraph_DecodeDigits (0);
	bargraph_NoDecodeDigits (1);
	bargraph_DecodeDigits (2);
	bargraph_DecodeDigits (3);

	// initialize cue list
	cue = 0;

	// level bar graph
	rising = TRUE;
	falling = FALSE;
	levelGraph_SetGains (1.0/100.0, 1.0/250.0);
	levelGraph_SetNoiseGainOffset (5.0, 2.5);
	levelGraph_SetTarget (20);

	// random blips on activity bar graph
	activityGraphTimer = 0;
	activityGraphState = 0;
	activityGraphCounter = 0;
	activityGraphActivity = 1;

	// low oscillating levels on the two containment field bar graphs and numeric displays
	leftcf_SetUserTarget (4.1);
	leftcf_Tick ();
	rightcf_SetUserTarget (4.1);
	rightcf_Tick ();

	redAlert = 0;
}


void roll_QuickTasks (void)
{
	int key;

	// echo DTMF tones to screen, could also do tasks that depend on tones here
	if (Xil_In32 (ZCU_DTMF_KEY_FLAG) & 0x1) {
		key = Xil_In32 (ZCU_DTMF_KEY_DATA);
		xil_printf ("DTMF: %c\n\r", key);

		// left containment field bar graph
		if (key == '2' || key == '3') {
			leftcf_Bump ();
		}

		// right containment field bar graph
		if (key == '1' || key == '3') {
			rightcf_Bump ();
		}

		if (key == '3') {
			leftcf_SetUserTarget (14.5);
			rightcf_SetUserTarget (14.5);
		}

		if (key == '9') {
			leftcf_SetUserTarget (4.1);
			rightcf_SetUserTarget (4.1);
		}

		if (key == '#') {
			activityGraphState = 1;
			activityGraphTimer = 100;
		}

		if (key == '4') {
			redAlert = 1;
		} else if (key == '8') {
			redAlert = 0;
		}
	}

	// run a list of cues, when elapsed time >= next cue time, call function associated with that cue
	if (cue < NUM_CUES) {
		if (Xil_In32 (ZCU_ELAPSED_TIME) > cues[cue].time) {
			if (cues[cue].action != NULL) {
				cues[cue].action ();
			}
			cue++;
		}
	}
}


void roll_TickTasks (void)
{
	int milliseconds;
	int tenths;
	int first, last;

	// display elapsed time on virus level numeric digits
	milliseconds = Xil_In32 (ZCU_ELAPSED_TIME);
	tenths = milliseconds / 100;
	bargraph_SetDigits (0, 1, tenths);

	// level bar graph -- once target is reached, restore gains so that noise functions properly
	levelGraph_Tick ();
	if (rising && levelGraph_GetActual () >= 20) {
		rising = FALSE;
		levelGraph_SetGains (0.125, 0.125);
	} else if (falling && levelGraph_GetActual () <= 3.5) {
		falling = FALSE;
		levelGraph_SetGains (0.125, 0.125);
		levelGraph_SetNoiseGainOffset (2.0, 1.0);
	}

	// activity bar graph
	switch (activityGraphState) {

		case 0:
			activityGraphTimer++;
			if (activityGraphTimer >= 33) {
				activityGraphTimer = 0;
				activityGraphCounter = ((float)rand())/((float)RAND_MAX) * 32.0 + 1;
				bargraph_SetDotFromLeft (1, activityGraphCounter);
			}
			break;

		case 1:
			activityGraphTimer++;
			if (activityGraphTimer >= 2) {
				activityGraphTimer = 0;
				activityGraphCounter++;
				if (activityGraphCounter >= 32) {
					activityGraphCounter = 0;
				}
				first = activityGraphCounter + 1;
				last = activityGraphCounter + activityGraphActivity;
				bargraph_SetRange32 (1, first, last);
			}
			break;
	}

	// low oscillating levels on the two containment field bar graphs and numeric displays
	leftcf_Tick ();
	rightcf_Tick ();

	// blink danger light
	if (dangerLightBlinkEnable) {
		dangerLightBlinkTimer++;
		if (dangerLightBlinkTimer >= 25) {
			dangerLightBlinkTimer = 0;
			dangerLightBlinkState = (dangerLightBlinkState + 1) & 0x1;
		}
		Xil_Out32 (ZCU_LIGHTS, (Xil_In32 (ZCU_LIGHTS) & ~ZCU_DANGER_LIGHT) | (dangerLightBlinkState ? ZCU_DANGER_LIGHT : 0x00));
	} else {
		dangerLightBlinkTimer = 0;
		dangerLightBlinkState = 1; // to cause immediate turn on once blink is enabled
		Xil_Out32 (ZCU_LIGHTS, Xil_In32 (ZCU_LIGHTS) & ~ZCU_DANGER_LIGHT);
	}

	// blink purge light
	if (purgeLightBlinkEnable) {
		purgeLightBlinkTimer++;
		if (purgeLightBlinkTimer >= 12) {
			purgeLightBlinkTimer = 0;
			purgeLightBlinkState = (purgeLightBlinkState + 1) & 0x1;
		}
		Xil_Out32 (ZCU_LIGHTS, (Xil_In32 (ZCU_LIGHTS) & ~ZCU_PURGE_LIGHT) | (purgeLightBlinkState ? ZCU_PURGE_LIGHT : 0x00));
	} else {
		purgeLightBlinkTimer = 0;
		purgeLightBlinkState = 1; // to cause immediate turn on once blink is enabled
		Xil_Out32 (ZCU_LIGHTS, Xil_In32 (ZCU_LIGHTS) & ~ZCU_PURGE_LIGHT);
	}

	// update dmx levels
	sine_Tick ();
	if (redAlert) {
		for (int i = 0; i < DMX_UNI_0_NUM_CHANS; i++) {
			dmx0_tx_buffer[i] = 0;
		}
		dmx0_tx_buffer[0] = 0xff;
		dmx0_tx_buffer[3] = 0xff;
		dmx0_tx_buffer[6] = 0xff;
	} else {
		sine_MapToDmx ();
	}

	// transmit dmx levels
	dmx_Transmit ();
}


static void roll_SetClusterLightToAmber (void)
{
	Xil_Out32 (ZCU_LIGHTS, (Xil_In32 (ZCU_LIGHTS) & ~ZCU_CLUSTER_PILOT_LIGHT_MASK) | ZCU_CLUSTER_PILOT_LIGHT_AMBER);
}


static void roll_SetClusterLightToRed (void)
{
	Xil_Out32 (ZCU_LIGHTS, (Xil_In32 (ZCU_LIGHTS) & ~ZCU_CLUSTER_PILOT_LIGHT_MASK) | ZCU_CLUSTER_PILOT_LIGHT_RED);
}


static void roll_Depressurize (void)
{
	levelGraph_SetGains (1.0/100.0, 1.0/250.0);
	levelGraph_SetTarget (3.5);
	falling = TRUE;
}

static void roll_BlinkDangerLight (void)
{
	dangerLightBlinkEnable = TRUE;
}


static void roll_BlinkPurgeLight (void)
{
	purgeLightBlinkEnable = TRUE;
}


static void roll_IncreaseActivity (void)
{
	activityGraphActivity++;
}
