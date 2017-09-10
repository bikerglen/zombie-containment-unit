/*
 * sine.h
 *
 *  Created on: Sep 9, 2017
 *      Author: glen
 */

#ifndef SRC_SINE_H_
#define SRC_SINE_H_

#define SINE_CHANNELS 25

extern uint8_t sine_out[SINE_CHANNELS];

void sine_Init (void);
void sine_Tick (void);
void sine_MapToDmx (void);

#endif /* SRC_SINE_H_ */
