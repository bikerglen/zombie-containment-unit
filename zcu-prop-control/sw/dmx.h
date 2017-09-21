/*
 * dmx.h
 *
 *  Created on: Sep 9, 2017
 *      Author: glen
 */

#ifndef SRC_DMX_H_
#define SRC_DMX_H_

#define DMX_UNI_0_NUM_CHANS 64

extern uint8_t dmx0_tx_buffer[DMX_UNI_0_NUM_CHANS];

void dmx_Init (void);
void dmx_ClearBuffer (void);
void dmx_Transmit (void);

#endif /* SRC_DMX_H_ */
