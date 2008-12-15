/*****************************************************************************
**																			**
**	 Name: 	FIO pins, Interrupts, and Timer in C							**	
**																			**
******************************************************************************

Analog Devices, Inc.  All rights reserved.

Pjoject Name:	BF537 Flags C

Date Modified:	12/10/04	Ver 0.0

Hardware:		ADSP-BF537 EZ-KIT Lite

Connections:	Switch SW5_1 has to be turned on in order to connect PB1 to PORTF2

Purpose:		To demonstrate the configuration of FIO pins, Timer, and
				Interrupts in C

*****************************************************************************/

#include "BF537-Flags.h"
//#include "ccblkfn.h"
#include "sysreg.h"

//--------------------------------------------------------------------------//
// Variables																//
//--------------------------------------------------------------------------//
// flag indicating direction of moving light (toggled in PORTF IntA ISR)
short sLight_Move_Direction = 0;
unsigned short ucActive_LED = 0x0020;

//--------------------------------------------------------------------------//
// Function:	main														//
//--------------------------------------------------------------------------//
int main(void)
{
	Init_Flags();
	Init_Timers();
	Init_Interrupts();

	while(1);
	return 0;
}

