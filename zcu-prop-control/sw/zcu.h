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
 * zcu.h
 *
 *  Created on: Feb 22, 2017
 *      Author: glen
 */

#ifndef SRC_ZCU_H_
#define SRC_ZCU_H_

enum ZcuRegisterAddresses {
	ZCU_AUDIO_OUT_UNMUTE			= XPAR_ZCU_ILA_0_BASEADDR + 0x00,
	ZCU_AUDIO_OUT_SELECT 			= XPAR_ZCU_ILA_0_BASEADDR + 0x04,
	ZCU_DTMF_IN_SELECT 				= XPAR_ZCU_ILA_0_BASEADDR + 0x08,
	ZCU_LEDS 						= XPAR_ZCU_ILA_0_BASEADDR + 0x0C,
	ZCU_RELAYS 						= XPAR_ZCU_ILA_0_BASEADDR + 0x10,
	ZCU_ELAPSED_TIME 				= XPAR_ZCU_ILA_0_BASEADDR + 0x14,
	ZCU_DTMF_KEY_FLAG 				= XPAR_ZCU_ILA_0_BASEADDR + 0x18,
	ZCU_DTMF_KEY_DATA 				= XPAR_ZCU_ILA_0_BASEADDR + 0x1C,
	ZCU_TICK_TIMER_FLAGS			= XPAR_ZCU_ILA_0_BASEADDR + 0x20,
	ZCU_LIGHTS 						= XPAR_ZCU_ILA_0_BASEADDR + 0x24,

	ZCU_DMX_TX_UNIVERSE_0			= XPAR_WS2811_16X128_0_BASEADDR + 0x80,
	ZCU_DMX_TX_UNIVERSE_1			= XPAR_WS2811_16X128_0_BASEADDR + 0x84,
	ZCU_DMX_TX_UNIVERSE_2			= XPAR_WS2811_16X128_0_BASEADDR + 0x88,
	ZCU_DMX_TX_UNIVERSE_3			= XPAR_WS2811_16X128_0_BASEADDR + 0x8C
};

enum ZcuSystemStates {
	STATE_NONE = 0,
	STATE_DETECT = 1,
	STATE_IDLE = 2,
	STATE_ROLL = 3
};

#define ZCU_CLUSTER_PILOT_LIGHT_MASK 0xF

enum ZcuClusterPilotLightColors {
	ZCU_CLUSTER_PILOT_LIGHT_OFF = 0,
	ZCU_CLUSTER_PILOT_LIGHT_AMBER = 1,
	ZCU_CLUSTER_PILOT_LIGHT_GREEN = 2,
	ZCU_CLUSTER_PILOT_LIGHT_BLUE = 4,
	ZCU_CLUSTER_PILOT_LIGHT_RED = 8
};

#define ZCU_DANGER_LIGHT 0x10
#define ZCU_PURGE_LIGHT 0x20
#define ZCU_RIGHT_LIGHT 0x40
#define ZCU_LEFT_LIGHT 0x80

#endif /* SRC_ZCU_H_ */
