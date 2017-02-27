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
