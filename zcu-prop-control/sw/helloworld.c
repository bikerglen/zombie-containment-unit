/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xstatus.h"
#include "xiic.h"
#include "xuartlite.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "sleep.h"

#include "zcu.h"
#include "bargraph.h"
#include "levelbg.h"
#include "fieldbg.h"
#include "detect.h"
#include "idle.h"
#include "roll.h"

#define IIC_SLAVE_ADDR			0x1A //for Zybo 0b0011010

XStatus fnAudioWriteToReg(u8 u8RegAddr, u16 u8Data);
XStatus fnAudioReadFromReg(u8 u8RegAddr, u8 *u8RxData);
XStatus fnAudioStartupConfig (void);

enum adauRegisterAdresses {
	R0_LEFT_ADC_VOL									= 0x00,
	R1_RIGHT_ADC_VOL								= 0x01,
	R2_LEFT_DAC_VOL						 			= 0x02,
	R3_RIGHT_DAC_VOL								= 0x03,
	R4_ANALOG_PATH				 					= 0x04,
	R5_DIGITAL_PATH				 					= 0x05,
	R6_POWER_MGMT					 				= 0x06,
	R7_DIGITAL_IF					 				= 0x07,
	R8_SAMPLE_RATE							 		= 0x08,
	R9_ACTIVE								 		= 0x09,
	R15_SOFTWARE_RESET				 				= 0x0F,
	R16_ALC_CONTROL_1								= 0x10,
	R17_ALC_CONTROL_2								= 0x11,
	R18_ALC_CONTROL_2								= 0x12
};

int main()
{
	int ch;
	int state = STATE_NONE;

    init_platform();

    print("Hello, world!\n\r");

    // cycle through LEDs
    Xil_Out32 (ZCU_LEDS, 0x20);
    Xil_Out32 (ZCU_LEDS, 0x28);
    Xil_Out32 (ZCU_LEDS, 0x24);
    Xil_Out32 (ZCU_LEDS, 0x22);
    Xil_Out32 (ZCU_LEDS, 0x21);
    Xil_Out32 (ZCU_LEDS, 0x20);
    Xil_Out32 (ZCU_LEDS, 0x00);

    // initialize audio codec
    fnAudioStartupConfig ();

	// set mute_n high (mute is an active-low signal)
	Xil_Out32 (ZCU_AUDIO_OUT_UNMUTE, 0x1);

	// pass input audio out to headphone jack
	Xil_Out32 (ZCU_AUDIO_OUT_SELECT, 0x1);

    // route right channel to dtmf decoder
	Xil_Out32 (ZCU_DTMF_IN_SELECT, 0x1);

	bargraph_SpiInit ();
	bargraph_Init (0);
	bargraph_Init (1);
	bargraph_Init (2);
	bargraph_Init (3);
	levelGraph_Init (0.125, 0.125);
	leftcf_Init ();
	rightcf_Init ();

	while (1) {

		// check status register of uart connected to sync control board for new state information
		if (Xil_In32 (XPAR_AXI_UARTLITE_0_BASEADDR + 0x8) & 0x1) {
			// get character from rx data register
			ch = Xil_In32 (XPAR_AXI_UARTLITE_0_BASEADDR + 0x0);
			switch (ch) {
				case 'D':
					if (state != STATE_DETECT) {
						state = STATE_DETECT;
						detect_Init ();
					}
					break;
				case 'I':
					if (state != STATE_IDLE) {
						state = STATE_IDLE;
						idle_Init ();
					}
					break;
				case 'P':
				case 'R':
					if (state != STATE_ROLL) {
						state = STATE_ROLL;
						roll_Init ();
					}
					break;
			}
		}

		// run quick tasks
		switch (state) {
			case STATE_DETECT:
				detect_QuickTasks ();
				break;
			case STATE_IDLE:
				idle_QuickTasks ();
				break;
			case STATE_ROLL:
				roll_QuickTasks ();
				break;
		}

		// if timer has expired since last time through loop, run 50 Hz tick tasks
		if (Xil_In32 (ZCU_TICK_TIMER_FLAGS) & 0x1) {
			Xil_Out32 (ZCU_TICK_TIMER_FLAGS, 0x1);
			switch (state) {
				case STATE_DETECT:
					detect_TickTasks ();
					break;
				case STATE_IDLE:
					idle_TickTasks ();
					break;
				case STATE_ROLL:
					roll_TickTasks ();
					break;
			}
		}
    }

    cleanup_platform();
    return 0;
}


/******************************************************************************
 * Function to write one byte (8-bits) to one of the registers from the audio
 * controller.
 *
 * @param	u8RegAddr is the LSB part of the register address (0x40xx).
 * @param	u8Data is the data byte to write.
 *
 * @return	XST_SUCCESS if all the bytes have been sent to Controller.
 * 			XST_FAILURE otherwise.
 *****************************************************************************/
XStatus fnAudioWriteToReg(u8 u8RegAddr, u16 u8Data) {

	u8 u8TxData[2];
	u8 u8BytesSent;

	u8TxData[0] = u8RegAddr << 1;
	u8TxData[0] = u8TxData[0] | ((u8Data>>8) & 0b1);

	u8TxData[1] = u8Data & 0xFF;

	u8BytesSent = XIic_Send(XPAR_AXI_IIC_0_BASEADDR, IIC_SLAVE_ADDR, u8TxData, 2, XIIC_STOP);

	//check if all the bytes where sent
	if (u8BytesSent != 3)
	{
		//return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/******************************************************************************
 * Function to read one byte (8-bits) from the register space of audio controller.
 *
 * @param	u8RegAddr is the LSB part of the register address (0x40xx).
 * @param	u8RxData is the returned value
 *
 * @return	XST_SUCCESS if the desired number of bytes have been read from the controller
 * 			XST_FAILURE otherwise
 *****************************************************************************/
XStatus fnAudioReadFromReg(u8 u8RegAddr, u8 *u8RxData) {

	u8 u8TxData[2];
	u8 u8BytesSent, u8BytesReceived;

	u8TxData[0] = u8RegAddr;
	u8TxData[1] = IIC_SLAVE_ADDR;

	u8BytesSent = XIic_Send(XPAR_AXI_IIC_0_BASEADDR, IIC_SLAVE_ADDR, u8TxData, 2, XIIC_STOP);
	//check if all the bytes where sent
	if (u8BytesSent != 2)
	{
		return XST_FAILURE;
	}

	u8BytesReceived = XIic_Recv(XPAR_AXI_IIC_0_BASEADDR, IIC_SLAVE_ADDR, u8RxData, 1, XIIC_STOP);
	//check if there are missing bytes
	if (u8BytesReceived != 1)
	{
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}


/******************************************************************************
 * Configure the initial settings of the audio controller, the majority of
 * these will remain unchanged during the normal functioning of the code.
 * In order to generate a correct BCLK and LRCK, which are crucial for the
 * correct operating of the controller, the sampling rate must me set in the
 * I2S_TRANSFER_CONTROL_REG. The sampling rate options are:
 *    "000" -  8 KHz
 *    "001" - 12 KHz
 *    "010" - 16 KHz
 *    "011" - 24 KHz
 *    "100" - 32 KHz
 *    "101" - 48 KHz
 *    "110" - 96 KHz
 * These options are valid only if the I2S controller is in slave mode.
 * When In master mode the ADAU will generate the appropriate BCLK and LRCLK
 * internally, and the sampling rates which will be set in the I2S_TRANSFER_CONTROL_REG
 * are ignored.
 *
 * @param	none.
 *
 * @return	XST_SUCCESS if the configuration is successful
 *****************************************************************************/
XStatus fnAudioStartupConfig (void)
{

	int Status;

	Status = fnAudioWriteToReg(R15_SOFTWARE_RESET, 0b000000000);
	Status = XST_SUCCESS;
	if (Status == XST_FAILURE)
	{
		xil_printf("\r\nError: could not write R15_SOFTWARE_RESET (0x00)");
		return XST_FAILURE;
	}
	usleep(1000);

	Status = fnAudioWriteToReg(R6_POWER_MGMT, 0b000010000);
	if (Status == XST_FAILURE)
	{
		xil_printf("\r\nError: could not write R6_POWER_MGMT (0b000010000)");
		return XST_FAILURE;
	}

	fnAudioWriteToReg(R0_LEFT_ADC_VOL, 0b000010111);
	fnAudioWriteToReg(R1_RIGHT_ADC_VOL, 0b000010111);
	fnAudioWriteToReg(R2_LEFT_DAC_VOL, 0b101111001);
	fnAudioWriteToReg(R3_RIGHT_DAC_VOL, 0b101111001);
	fnAudioWriteToReg(R4_ANALOG_PATH, 0b000010000);
	fnAudioWriteToReg(R5_DIGITAL_PATH, 0b000000000);
	fnAudioWriteToReg(R7_DIGITAL_IF, 0b000000010);
	fnAudioWriteToReg(R8_SAMPLE_RATE, 0b000001100);
	fnAudioWriteToReg(R9_ACTIVE, 0b000000001);

	usleep(1000);

	if (Status == XST_FAILURE)
	{
		xil_printf("\r\nError: could not write R6_POWER_MGMT (0b000000000)");
		return XST_FAILURE;
	}

	Status = fnAudioWriteToReg(R6_POWER_MGMT, 0b000000000);
	if (Status == XST_FAILURE)
	{
		xil_printf("\r\nError: could not write R6_POWER_MGMT (0b000000000)");
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}
