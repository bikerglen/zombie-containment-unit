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
