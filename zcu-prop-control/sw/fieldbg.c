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
 * fieldbg.c
 *
 *  Created on: Feb 24, 2017
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
#include "bargraph.h"
#include "fieldbg.h"

static float leftContainmentActual;
static float leftContainmentTarget;
static int   leftContainmentHoldTimer;
static int   leftNoiseTimer = 0;
static float leftBarNoise = 0;
static float leftUserTarget = 4.1;

static float rightContainmentActual;
static float rightContainmentTarget;
static int   rightContainmentHoldTimer;
static int   rightNoiseTimer = 0;
static float rightBarNoise = 0;
static float rightUserTarget = 4.1;


void leftcf_Init (void)
{
	leftNoiseTimer = 0;
	leftContainmentActual = 0;
	leftContainmentTarget = 4.1;
	leftContainmentHoldTimer = 0;
	leftBarNoise = 0;
	leftUserTarget = 4.1;
}


void leftcf_Tick (void)
{
	float error;
	int n;

	// generate some noise every 64/50 second
	leftNoiseTimer = (leftNoiseTimer + 1) & 0x0f;
	if (leftNoiseTimer == 10) {
		leftBarNoise = ((float)rand())/((float)RAND_MAX) * 2.0 - 1.0;
	}

	// left containment field bar graph; rise quick, fall slow
	if (leftContainmentHoldTimer != 0) {
		leftContainmentHoldTimer = leftContainmentHoldTimer - 1;
	} else {
		leftContainmentTarget = leftUserTarget + leftBarNoise;
	}
	error = leftContainmentTarget - leftContainmentActual;
	leftContainmentActual = leftContainmentActual + ((error < 0) ? (error/32) : (error/4));
	n = (leftContainmentActual < 0) ? (0) : ((leftContainmentActual > 18) ? (18) : (leftContainmentActual));
	bargraph_SetBarFromRight18 (2, n);
	if ((leftNoiseTimer & 0xF) == 1) {
		bargraph_SetDigits (2, 1, leftContainmentActual*10.0);
	}
}


void leftcf_Bump (void)
{
	leftContainmentTarget = 17.1;
	leftContainmentHoldTimer = 10;
}


void leftcf_SetUserTarget (float t)
{
	leftUserTarget = t;
}


void rightcf_Init (void)
{
	rightNoiseTimer = 0;
	rightContainmentActual = 0;
	rightContainmentTarget = 4.1;
	rightContainmentHoldTimer = 0;
	rightBarNoise = 0;
	rightUserTarget = 4.1;
}


void rightcf_Tick (void)
{
	float error;
	int n;

	// generate some noise every 64/50 second
	rightNoiseTimer = (rightNoiseTimer + 1) & 0x0f;
	if (rightNoiseTimer == 10) {
		rightBarNoise = ((float)rand())/((float)RAND_MAX) * 2.0 - 1.0;
	}

	// right containment field bar graph; rise quick, fall slow
	if (rightContainmentHoldTimer != 0) {
		rightContainmentHoldTimer = rightContainmentHoldTimer - 1;
	} else {
		rightContainmentTarget = rightUserTarget + rightBarNoise;
	}
	error = rightContainmentTarget - rightContainmentActual;
	rightContainmentActual = rightContainmentActual + ((error < 0) ? (error/32) : (error/4));
	n = (rightContainmentActual < 0) ? (0) : ((rightContainmentActual > 18) ? (18) : (rightContainmentActual));
	bargraph_SetBarFromLeft18 (3, n);
	if ((rightNoiseTimer & 0xF) == 1) {
		bargraph_SetDigits (3, 1, rightContainmentActual*10.0);
	}
}


void rightcf_Bump (void)
{
	rightContainmentTarget = 17.1;
	rightContainmentHoldTimer = 10;
}


void rightcf_SetUserTarget (float t)
{
	rightUserTarget = t;
}

