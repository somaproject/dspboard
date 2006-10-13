//
// crt0.asm
//
// This is the startup code to get a supervisor program going.
//
// For BF533 and BF537 only
// 2004, 2005 Martin Strubel <hackfin@section5.ch>
//
// $Id: crt0.asm,v 1.3 2006/01/22 17:08:05 strubi Exp $
//
//

.text;
#include <defBF533.h>

#include "config.h"

////////////////////////////////////////////////////////////////////////////
// core clock dividers -- DO NOT CHANGE!
#define CCLK_1 0x00
#define CCLK_2 0x10
#define CCLK_4 0x20
#define CCLK_8 0x30

// little macro trick to resolve macros before concatenating:
#define _GET_CCLK(x) CCLK_##x
#define GET_CCLK(x) _GET_CCLK(x)

// Short bootstrap

.global start
start:

	sp.h = 0xFFB0;		//Set up supervisor stack in scratch pad
	sp.l = 0x0400;
	fp = sp;


////////////////////////////////////////////////////////////////////////////
// PLL and clock setups
//
//



setupPLL:
	// we have to enter the idle state after changes applied to the
	// VCO clock, because the PLL needs to lock in on the new clocks.


	p0.l = LO(PLL_CTL);
	p0.h = HI(PLL_CTL);
	r1 = w[p0](z);
	r2 = r1;  
	r0 = 0(z);
		
	r0.l = ~(0x3f << 9);
	r1 = r1 & r0;
	r0.l = ((VCO_MULTIPLIER & 0x3f) << 9);
	r1 = r1 | r0;


 	p1.l = LO(SIC_IWR);  // enable PLL Wakeup Interrupt
	p1.h = HI(SIC_IWR);

	r0 = [p1];			
	bitset(r0,0);	  
	[p1] = r0;
	
 	w[p0] = r1;          // Apply PLL_CTL changes.
	ssync;
 	
	cli r0;
 	idle;	// wait for Loop_count expired wake up
	sti r0;

	// now, set clock dividers:
	p0.l = LO(PLL_DIV);
	p0.h = HI(PLL_DIV);


	// SCLK = VCOCLK / SCLK_DIVIDER
	r0.l = (GET_CCLK(CCLK_DIVIDER) | (SCLK_DIVIDER & 0x000f));


	w[p0] = r0; // set Core and system clock dividers


	// not needed in reset routine: sti r1;

////////////////////////////////////////////////////////////////////////////
// install default interrupt handlers

	p0.l = LO(EVT2);
	p0.h = HI(EVT2);

	r0.l = _NHANDLER;
	r0.h = _NHANDLER;  	// NMI Handler (Int2)
    [p0++] = r0;

    r0.l = EXC_HANDLER;
  	r0.h = EXC_HANDLER;  	// Exception Handler (Int3)
    [p0++] = r0;
	
	[p0++] = r0; 		// IVT4 isn't used

    r0.l = _HWHANDLER;
	r0.h = _HWHANDLER; 	// HW Error Handler (Int5)
    [p0++] = r0;
	
    r0.l = _THANDLER;
	r0.h = _THANDLER;  	// Timer Handler (Int6)
	[p0++] = r0;
	
    r0.l = _RTCHANDLER;
	r0.h = _RTCHANDLER; // IVG7 Handler
	[p0++] = r0;
	
    r0.l = _rxisr;
	r0.h = _rxisr;  	// IVG8 Handler
  	[p0++] = r0;
  	
     r0.l = _I9HANDLER;
	r0.h = _I9HANDLER; 	// IVG9 Handler
 	[p0++] = r0;
 	
    r0.l = _I10HANDLER;
	r0.h = _I10HANDLER;	// IVG10 Handler
 	[p0++] = r0;
 	
    r0.l = _I11HANDLER;
	r0.h = _I11HANDLER;	// IVG11 Handler
  	[p0++] = r0;
  	
    r0.l = _I12HANDLER;
	r0.h = _I12HANDLER;	// IVG12 Handler
  	[p0++] = r0;
  	
    r0.l = _I13HANDLER;
	r0.h = _I13HANDLER;	// IVG13 Handler
    [p0++] = r0;

    r0.l = _I14HANDLER;
	r0.h = _I14HANDLER;	// IVG14 Handler
  	[p0++] = r0;

    r0.l = _I15HANDLER;
	r0.h = _I15HANDLER;	// IVG15 Handler
	[p0++] = r0;


	

	// we want to run our program in supervisor mode,
	// therefore we need a few tricks:


	//  Enable Interrupt 15 
	p0.l = LO(EVT15);
	p0.h = HI(EVT15);
	r0.l = call_main;  // install isr 15 as caller to main
	r0.h = call_main;
	[p0] = r0;

	r0 = 0xFFFF(z);    // enable all IRQs
	sti r0;            // set mask
	raise 15;          // raise sw interrupt
	
	p0.l = wait;
	p0.h = wait;

	reti = p0;
	rti;               // return from reset

wait:
	jump wait;         // wait until irq 15 is being serviced.


call_main:

	// enable the cycle counter
	r2 = 0;
	cycles = r2;
	cycles2 = r2;
	r2 = syscfg;
	bitset(r2, 1);
	syscfg = r2;
	
	[--sp] = reti;  // pushing RETI allows interrupts to occur inside all main routines

	
	p0.l = _main;
	p0.h = _main;

	r0.l = end;
	r0.h = end;

	rets = r0;      // return address for main()'s RTS

	jump (p0);

end:
	idle;
	jump end;


.global idle_loop
idle_loop:
	idle;
	ssync;
	jump idle_loop;


start.end:

////////////////////////////////////////////////////////////////////////////
// SETUP ROUTINES
//




////////////////////////////////////////////////////////////////////////////
// Default handlers:
//


// If we get caught in one of these handlers for some reason, 
// display the IRQ vector on the EZKIT LEDs and enter
// endless loop.

display_fail:
	bitset(r0, 5);    // mark error
#ifdef EXCEPTION_REPORT
	call EXCEPTION_REPORT;
#endif
	jump stall;


_HWHANDLER:           // HW Error Handler 5
	nop			;
	nop			;
	nop			;  
rti;

_NHANDLER:
stall:
	jump stall;

EXC_HANDLER:          // exception handler
#ifdef EXCEPTION_REPORT
	r0 = seqstat;
	r1 = retx;
	call EXCEPTION_REPORT;
	cc = r0 == 0;
	if !cc jump cont_program;
#endif
	jump idle_loop;
cont_program:
	rtx;

_THANDLER:            // Timer Handler 6	
	r0.l = 6;
	jump display_fail;

_RTCHANDLER:          // IVG 7 Handler  
	r0.l = 7;
	jump display_fail;
	rti			;
	
_I8HANDLER:           // IVG 8 Handler
	nop
	rti;  

_I9HANDLER:           // IVG 9 Handler
	nop;
	rti;  


_I10HANDLER:          // IVG 10 Handler
	r0.l = 10;
	jump display_fail;

_I11HANDLER:          // IVG 11 Handler
	r0.l = 11;
	jump display_fail;

_I12HANDLER:          // IVG 12 Handler
	r0.l = 12;
	
	rti
	
	
_I13HANDLER:		  // IVG 13 Handler
	r0.l = 13;
	jump display_fail;
 
_I14HANDLER:		  // IVG 14 Handler
	r0.l = 14;
	jump display_fail;

_I15HANDLER:		  // IVG 15 Handler
	r0.l = 15;
	jump display_fail;
	
	
////////////////////////////////////////////////////////////////////////////
// we need _atexit if we don't use a libc..
#ifndef USE_LIBC

.global _atexit;
_atexit:
	rts;

#endif
