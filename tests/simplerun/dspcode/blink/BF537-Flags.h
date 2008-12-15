#ifndef  __BF537_FLAGS_DEFINED
	#define __BF537_FLAGS_DEFINED

//--------------------------------------------------------------------------//
// Header files																//
//--------------------------------------------------------------------------//
#include <sys/exception.h>
#include <cdefBF537.h>

//--------------------------------------------------------------------------//
// Symbolic constants														//
//--------------------------------------------------------------------------//

//--------------------------------------------------------------------------//
// Global variables															//
//--------------------------------------------------------------------------//
extern short sLight_Move_Direction;
extern unsigned short ucActive_LED;
//--------------------------------------------------------------------------//
// Prototypes																//
//--------------------------------------------------------------------------//
// in file Initialization.c
void Init_Flags(void);
void Init_Timers(void);
void Init_Interrupts(void);
// in file ISRs.c

void Timer0_ISR () __attribute__((interrupt_handler));
void PORTF_IntA_ISR () __attribute__((interrupt_handler));
#endif //__BF537_FLAGS_DEFINED

