/*
SOMA DSP CODE
Copyright Eric Jonas 2002-2003
jonas@cortical.mit.edu
Wilson Lab
Picower Center for Learning and Memory
Massachusetts Institute of Technology


This is the main DSP code. See "ADSP-21065L core.ai" for
a more in-depth explanation. 

To get started, there are three main routines:

boot : initial boot loader, executed when system is bootstrapped from FPGA pretending
to be boot-prom, and then DMAs-in remaining code

timer: takes care of the system timer. External interrupts on IRQ2 increment the timer, counting
in 100uS timestamps, which are cleared when this interrupt happens and TCLR (flag 4) is high. 

main: main routine, ISR for IRQ0. Detailed explanation can be found in above-mentioned documentation. 

*/

#include "def21065l.h"
/*  Interupt Vector Table.								*/
.SECTION/PM     isr_tabl;

/* The loader begins with the interrupts up to and including the low    */
/*  priority timer interrupt.                                           */

		NOP;NOP;NOP;NOP;        /* Reserved interrupt          	 */

___lib_RSTI:    IDLE;                   /* Implicit IDLE instruction    */
		JUMP boot (DB); 	/* Begin loader                 		*/
		NOP;NOP;                /* Pad to next interrupt       	*/
		NOP;NOP;NOP;NOP;        /* Reserved interrupt          	*/

/* Vector for status stack/loop stack overflow or PC stack full:        */

___lib_SOVFI:   RTI;RTI;RTI;RTI;

/* Vector for high priority timer interrupt:                            */

___lib_TMZHI:  RTI; RTI;RTI;RTI;           

/* Vectors for external interrupts:                                     */

___lib_VIRPTI:  RTI;RTI;RTI;RTI;
___lib_IRQ2I:   JUMP timer (DB);
				bit set MODE1 SRRFL;NOP;NOP;
___lib_IRQ1I:   RTI;RTI;RTI;RTI; 
___lib_IRQ0I:   RTI;RTI;RTI;RTI;

NOP;NOP;NOP;NOP;                /* Reserved interrupt   */

/* Vectors for Serial port DMA channels:                                */

___lib_SPR0I:   RTI;RTI;RTI;RTI;
___lib_SPR1I:   RTI;RTI;RTI;RTI;
___lib_SPT0I:   RTI;RTI;RTI;RTI;
___lib_SPT1I:   RTI;RTI;RTI;RTI;

/* Vectors for link port DMA channels:                                  */
___lib_LP2I:    RTI;RTI;RTI;RTI;
___lib_LP3I:    RTI;RTI;RTI;RTI;

/* Vectors for External port DMA channels:                              */
___lib_EP0I:    RTI;RTI;RTI;RTI;
___lib_EP1I:    RTI;RTI;RTI;RTI;
___lib_EP2I:    RTI;RTI;RTI;RTI;
___lib_EP3I:    RTI;RTI;RTI;RTI;

/* Vector for Link service request                                      */
___lib_LSRQ:    RTI;RTI;RTI;RTI;

/* Vector for DAG1 buffer 7 circular buffer overflow                    */
___lib_CB7I:    RTI;RTI;RTI;RTI;

/* Vector for DAG2 buffer 15 circular buffer overflow    		*/
___lib_CB15I:   RTI;RTI;RTI;RTI;

/* Vector for lower priority timer interrupt   				*/
___lib_TMZLI:   RTI;RTI;RTI;RTI;

.SECTION/DM dm_data; 
/* all necessary buffers. */ 
// SAMPLE BUFFERS:
// positions for doing structure-like indirect addressing
#define BUFLEN 512;
#define FIRIIR_POS = 512; 
#define FILTERNUM_POS = 513;
#define THRESHOLD_POS = 514;
#define ENABLED_POS = 515; 

SAMPLEBUFFERS:
.var SAMPLES0[512], FIRIIR0, FILTERNUM0, THRESHOLD0, ENABLED0;
.var SAMPLES1[512], FIRIIR1, FILTERNUM1, THRESHOLD1, ENABLED1;
.var SAMPLES2[512], FIRIIR2, FILTERNUM2, THRESHOLD2, ENABLED2;
.var SAMPLES3[512], FIRIIR3, FILTERNUM3, THRESHOLD3, ENABLED3;
.var SAMPLESC[512], FIRIIRC, FILTERNUMC, THRESHOLDC, ENABLEDC;

.var TIME; 

.var CURRENTSAMPLE; // sample buffer circular pointer to head
.var WINCNT, NEXTWINCNT; // countdowns for windowed data collection of spike stuff
.var EVENTIN0[4], EVENTIN1[4], EVENTIN2[4], EVENTIN3[4]; 
.var EVENTOUT0[4], EVENTOUT1[4], EVENTOUT2[4], EVENTOUT3[4]; 

.var NEWSAMPLES[5];

.SECTION/PM pm_code;
boot: // boot routine


	// configure output flags
	R0 = IOCTL;
	R0 = bclr R0 by FLG40;
	dm(IOCTL) = R0; 

	// enable interrupts
	bit set imask IRQ0I | IRQ1I | IRQ2I; // enable external interrupts
	bit set MODE1 IRPTEN;
	R0 = 10000; 
dummyloop:
	R0 = R0 + 1; 
	nop;
	nop;
	nop;
	nop;
	jump dummyloop;

timer:	
	R0 = dm(IOSTAT); 			//Read IO status register
	btst R0 by 0; 				// test flag 4
	R0 = dm(TIME);				// load old TIME value
	R0 = R0+1; 					// increment old time value
	if NOT SZ R0 = R0 xor R0;	// reset to zero if Flag 4 is high
	dm(TIME) = R0;				// save value
	bit clr MODE1 SRRFL;
	rti; 



.SECTION/PM pm_data; 
/* This is where we store the filters, but they are programmable by the events */ 
FIRBASE:
#define FIRLEN 160+1
.var FIR0[160], FIR0LEN0;
.var FIR1[160], FIR0LEN1;
.var FIR2[160], FIR0LEN2;
.var FIR3[160], FIR0LEN3;
.var FIR4[160], FIR0LEN4;
.var FIR5[160], FIR0LEN5;
.var FIR6[160], FIR0LEN6;
.var FIR7[160], FIR0LEN7;
.var FIR8[160], FIR0LEN8;
.var FIR9[160], FIR0LEN9;
IIRBASE:
#define IIRLEN 32+1
.var IIR0[32], IIRLEN0;
.var IIR1[32], IIRLEN1;
.var IIR2[32], IIRLEN2;
.var IIR3[32], IIRLEN3;
.var IIR4[32], IIRLEN4;
.var IIR5[32], IIRLEN5;
.var IIR6[32], IIRLEN6;
.var IIR7[32], IIRLEN7;
.var IIR8[32], IIRLEN8;
.var IIR9[32], IIRLEN9;

.SECTION/DM port_data;



