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
 * roll.h
 *
 *  Created on: Feb 22, 2017
 *      Author: glen
 */

#ifndef SRC_ROLL_H_
#define SRC_ROLL_H_

typedef struct {
	int time;
	void (*action)(void);
} Cue;

void roll_Init (void);
void roll_QuickTasks (void);
void roll_TickTasks (void);

#endif /* SRC_ROLL_H_ */
