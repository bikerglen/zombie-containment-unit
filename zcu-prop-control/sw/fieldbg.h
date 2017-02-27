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
