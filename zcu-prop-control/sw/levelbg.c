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
 * levelbg.c
 *
 *  Created on: Feb 23, 2017
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
#include "levelbg.h"

static float levelGraphActual;
static float levelGraphTarget;
static float levelGraphNoise;
static int levelGraphNoiseTimer;
static float levelGraphAlpha, levelGraphBeta;
static float levelGraphNoiseGain;
static float levelGraphNoiseOffset;

void levelGraph_Init (float alpha, float beta)
{
	levelGraphActual = 0;
	levelGraphTarget = 0;
	levelGraphNoise = 0;
	levelGraphNoiseTimer = 0;
	levelGraphAlpha = alpha;
	levelGraphBeta = beta;
	levelGraphNoiseGain = 2.0;
	levelGraphNoiseOffset = 1.0;
}


void levelGraph_SetGains (float alpha, float beta)
{
	levelGraphAlpha = alpha;
	levelGraphBeta = beta;
}


void levelGraph_SetNoiseGainOffset (float gain, float offset)
{
	levelGraphNoiseGain = gain;
	levelGraphNoiseOffset = offset;
}


void levelGraph_SetTarget (float t)
{
	levelGraphTarget = t;
}


void levelGraph_Tick (void)
{
	float error;
	int n;

	// compute some pseudo-random noise to add to signal
	levelGraphNoiseTimer = levelGraphNoiseTimer + 1;
	if (levelGraphNoiseTimer == 40) {
		levelGraphNoiseTimer = 0;
		levelGraphNoise = ((float)rand())/((float)RAND_MAX) * levelGraphNoiseGain - levelGraphNoiseOffset;
	}

	error = levelGraphTarget + levelGraphNoise - levelGraphActual;
	levelGraphActual = levelGraphActual + ((error < 0) ? (levelGraphBeta*error) : (levelGraphAlpha*error));
	n = (levelGraphActual < 0) ? (0) : ((levelGraphActual > 24) ? (24) : (levelGraphActual));
	bargraph_SetBarFromLeft (0, n);
}


float levelGraph_GetActual (void)
{
	return levelGraphActual;
}
