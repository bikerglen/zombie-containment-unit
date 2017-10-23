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
 * levelbg.h
 *
 *  Created on: Feb 23, 2017
 *      Author: glen
 */

#ifndef SRC_LEVELBG_H_
#define SRC_LEVELBG_H_

void levelGraph_Init (float alpha, float beta);
void levelGraph_SetGains (float alpha, float beta);
void levelGraph_SetNoiseGainOffset (float gain, float offset);
void levelGraph_SetTarget (float t);
void levelGraph_Tick (void);
float levelGraph_GetActual (void);

#endif /* SRC_LEVELBG_H_ */
