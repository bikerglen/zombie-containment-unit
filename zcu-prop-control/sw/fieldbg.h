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
 * fieldbg.h
 *
 *  Created on: Feb 24, 2017
 *      Author: glen
 */

#ifndef SRC_FIELDBG_H_
#define SRC_FIELDBG_H_

void leftcf_Init (void);
void leftcf_Tick (void);
void leftcf_Bump (void);
void leftcf_SetUserTarget (float t);

void rightcf_Init (void);
void rightcf_Tick (void);
void rightcf_Bump (void);
void rightcf_SetUserTarget (float t);

#endif /* SRC_FIELDBG_H_ */
