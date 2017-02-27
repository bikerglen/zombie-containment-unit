/*
 * bargraph.h
 *
 *  Created on: Feb 22, 2017
 *      Author: glen
 */

#ifndef SRC_BARGRAPH_H_
#define SRC_BARGRAPH_H_

void bargraph_SpiInit (void);
void bargraph_SpiWrite (uint8_t which, uint8_t addr, uint8_t data);

void bargraph_Init (uint8_t which);

void bargraph_NoDecodeDigits (uint8_t which);
void bargraph_DecodeDigits (uint8_t which);

// these work for 24 or 32 segment bar graphs
void bargraph_SetDotFromLeft (uint8_t which, uint8_t dot);
void bargraph_SetDotFromRight (uint8_t which, uint8_t dot);
void bargraph_SetBarFromLeft (uint8_t which, uint8_t n);
// TODO -- void bargraph_SetBarFromRight (uint8_t which, uint8_t n);

// these work for 18 segment bar graphs
void bargraph_SetDotFromLeft18 (uint8_t which, uint8_t dot);
void bargraph_SetDotFromRight18 (uint8_t which, uint8_t dot);
void bargraph_SetBarFromLeft18 (uint8_t which, uint8_t n);
void bargraph_SetBarFromRight18 (uint8_t which, uint8_t n);

void bargraph_SpinDigitsInit (uint8_t mask);
void bargraph_SpinDigitsTick (uint8_t mask);

void bargraph_SetDigits (uint8_t select, uint8_t dp, uint16_t n);

void bargraph_SetRange32 (uint8_t select, int first, int last);

#endif /* SRC_BARGRAPH_H_ */
