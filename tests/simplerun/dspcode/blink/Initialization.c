#include "BF537-Flags.h"

//--------------------------------------------------------------------------//
// Function:	Init_Flags													//
//																			//
// Parameters:	None														//
//																			//
// Return:		None														//
//																			//
// Description:	This function configures PORTF2 as input for edge sensitive	//
//				interrupt generation.										//
//				The switch connected to PORTF2 (PB1) can be used to change  //
//				the direction of the moving light.							//
//--------------------------------------------------------------------------//
void Init_Flags(void)
{
	int temp;	
	
	temp = *pPORTF_FER;
	temp++;
#if (__SILICON_REVISION__ < 0x0001)
	*pPORTF_FER = 0x0000;
	*pPORTF_FER = 0x0000;
#else
	*pPORTF_FER = 0x0000;
#endif

	*pPORTFIO_INEN		= 0x0004;		// Pushbuttons 
	*pPORTFIO_DIR		= 0x0FC0;		// LEDs
	*pPORTFIO_EDGE		= 0x0004;
	*pPORTFIO_MASKA		= 0x0004;
	*pPORTFIO_SET 		= 0x0FC0;
	*pPORTFIO_CLEAR		= 0x0FC0;
}

//--------------------------------------------------------------------------//
// Function:	Init_Timers													//
//																			//
// Parameters:	None														//
//																			//
// Return:		None														//
//																			//
// Description:	This function initialises Timer0 for PWM mode.				//
//				It is used as reference for the 'shift-clock'.				//
//--------------------------------------------------------------------------//
void Init_Timers(void)
{
	*pTIMER0_CONFIG		= 0x0019;
	*pTIMER0_PERIOD		= 0x00800000;
	*pTIMER0_WIDTH		= 0x00400000;
	*pTIMER_ENABLE		= 0x0001;
}

//--------------------------------------------------------------------------//
// Function:	Init_Interrupts												//
//																			//
// Parameters:	None														//
//																			//
// Return:		None														//
//																			//
// Description:	This function initialises the interrupts for Timer0 and		//
//				PORTF_IntA (PORTF2).												//
//--------------------------------------------------------------------------//
void Init_Interrupts(void)
{
  int i;
	// assign core IDs to interrupts
	*pSIC_IAR0 = 0xffffffff;
	*pSIC_IAR1 = 0xffffffff;
	*pSIC_IAR2 = 0xffff4fff;					// Timer0 -> ID4; 
	*pSIC_IAR3 = 0xffff5fff;					// PORTF IntA -> ID5

	// assign ISRs to interrupt vectors
	//register_handler(ik_ivg11, Timer0_ISR);		// Timer0 ISR -> IVG 11
	//register_handler(ik_ivg12, PORTF_IntA_ISR);	// PORTF_IntA_ISR -> IVG 12
	*pEVT11 = Timer0_ISR;
	*pEVT12 = PORTF_IntA_ISR;

	asm volatile ("cli %0; bitset (%0, 11); bitset (%0, 12); sti %0; csync;": "+d"(i));

	// enable Timer0 and PORTF IntA interrupt
	*pSIC_IMASK = 0x08080000;
}

