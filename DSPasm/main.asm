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

#include "filters.asm"

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
			 
___lib_IRQ0I:   JUMP sample (DB);
				NOP; NOP; NOP; 

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



.SECTION/PM pm_data; 
/* This is where we store the filters, but they are programmable by the events.
   This is also where the output buffers are. */ 
FILTERS:
#define FILTERN 200
.VAR FILTER1[FILTERN] = "filter.dat";
.VAR FILTERTYPE1 = 0;
.VAr FILTERLEN1 = 100;
.VAR FILTER2[FILTERN], FILTERTYPE2, FILTERLEN2;
.VAR FILTER3[FILTERN], FILTERTYPE3, FILTERLEN3;
.VAR FILTER4[FILTERN], FILTERTYPE4, FILTERLEN4;
.VAR FILTERC[FILTERN], FILTERTYPEC, FILTERLENC;

#define SPIKEOUTN 160
#define CONTOUTN 40
.var SPIKEOUT[SPIKEOUTN];
.var SPIKEOUTPTR;
.var CONTOUT[CONTOUTN];
.var CONTOUTPTR; 

.SECTION/DM dm_data; 
/* all necessary buffers. */ 
// SAMPLE BUFFERS:
// positions for doing structure-like indirect addressing
#define XLEN 256
#define YLEN 256 
#define THRESHOLD_POS 512
#define ENABLED_POS 513
#define TOTALLEN 513

SAMPLEBUFFERS:
.VAR X1[XLEN], Y1[YLEN], YPOS1, THRESHOLD1, ENABLED1;
.VAR X2[XLEN], Y2[YLEN], YPOS2, THRESHOLD2, ENABLED2;
.VAR X3[XLEN], Y3[YLEN], YPOS3, THRESHOLD3, ENABLED3;
.VAR X4[XLEN], Y4[YLEN], YPOS4, THRESHOLD4, ENABLED4;
.VAR XC[XLEN], YC[YLEN], YPOSC, THRESHOLDC, ENABLEDC;

DELAYLINES:
#define DELAYN 40 
.VAR D1[DELAYN];
.VAR D2[DELAYN];
.VAR D3[DELAYN];
.VAR D4[DELAYN];
.VAR DC[DELAYN];


.VAR TIME; 

.VAR CURRENTSAMPLE; // sample buffer circular pointer to head
.VAR WINCNT, NEXTWINCNT; // countdowns for windowed data collection of spike stuff
.VAR EVENTIN0[4], EVENTIN1[4], EVENTIN2[4], EVENTIN3[4]; 
.VAR EVENTOUT0[4], EVENTOUT1[4], EVENTOUT2[4], EVENTOUT3[4]; 

.VAR NEWSAMPLES[5];

.SECTION/DM port_data;
.var NEWDATA[5]; 


.SECTION/PM pm_code;
boot: // boot routine


	// configure output flags
	R0 = IOCTL;
	R0 = bclr R0 by FLG40;
	dm(IOCTL) = R0; 


	// TEST
	b0 = 100; 
	//Setup input DAG pointers
	B3 = X1; 
	B4 = X2; 
	B5 = X3; 
	B6 = X4;
	B7 = XC; 
	
	M3 = 1; 

	L3 = XLEN;
	L4 = XLEN;
	L5 = XLEN;
	L6 = XLEN;
	L7 = XLEN; 

	
	// floating-point output pointers. 
 	R1 = Y1; 
	dm(YPOS1) = R1;
 	R1 = Y2; 
	dm(YPOS2) = R1;
 	R1 = Y3; 
	dm(YPOS3) = R1;
 	R1 = Y4; 
	dm(YPOS4) = R1;
 	R1 = YC; 
	dm(YPOSC) = R1;

	// fixed-point output DAG pointers
	b14 = SPIKEOUT; 
	l14 = SPIKEOUTN;
	m14 = 1;

	b15 = CONTOUT;
	l15 = CONTOUTN;
	m15 = 1; 
	

	// enable interrupts
	bit set imask IRQ0I | IRQ1I | IRQ2I; // enable external interrupts
	bit set MODE1 IRPTEN;

	R0 = 10000; 
dummyloop:
	R0 = R0 + 1; 
	r2 = pm(FILTERTYPE1);

	r2 = 0; 
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
	//bit clr MODE1 SRRFL;
	rti (DB); 

sample:
	// read-in new samples, convert to floating-point, store at head of x[n]
	R0 = dm(NEWDATA);
	R1 = dm(NEWDATA+1);
	R2 = dm(NEWDATA+2);
	R3 = dm(NEWDATA+3);
	R4 = dm(NEWDATA+4);

	F0 = float R0; 
	F1 = float R1; 
	F2 = float R2; 
	F3 = float R3; 
	F4 = float R4; 

	dm(I3, M3) = F0; // store new samples, incrementing in the process. 
	dm(I4, M3) = F1; // now the index pointer is at one beyond most recent sample
	dm(I5, M3) = F2; 
	dm(I6, M3) = F3;
	dm(I7, M3) = F4; 

	// Check to see if we need to DMA_out a spike chunk, and start the DMA

	// Filter the data !
	

	m8 = 1;  m0 = -1; // directions for buffers; we want to work backwards through x[n].
    l2 = YLEN;
   	m1 = 1; 
	
	channel_1:
		r2 = pm(FILTERTYPE1);
	    r1 = pm(FILTERLEN1);		// get length of filter
		l0 = XLEN; 
		b0 = b3; 
		i0 = i3; 
		f0 = dm(i0, m0);  // load f0 with most recent value, push ponter back one, 
 	    						   
		b8 = FILTER1;
		b1 = D1; 
		m0 = -1; 
		
		call filterchannel; 

		b2 = Y1;				// setup dmDAG register set 2 for output
		i2 = dm(YPOS1); 
		
		r1 = fix f8, dm(i2, m1) = f8;	// save result in circular buffer
		pm(i14, m14) = r1; 		// save output sample in spike buffer;
		dm(YPOS1) = i2; 

	rti; 


filterchannel:
/* call this to filter the channel, with 
	R2 = filter type
	R1 = Filter length
	f0 = most recent sample
	i0 = current position of sample buffer
	l0 = length of sample buffer
	b0 = base of sample buffer
	b1 = base of IIR intermediate values buffer; 
	b8 = coefficients
*/
	r2 = r2 - 1; 
	if eq jump filterchannel_iir;
		jump filterchannel_fir; 

filterchannel_iir:
	l1 = 0;
	l8 = 0; 
	call iir(DB); 
	b0 = b1; 
	l0 = 0; 


	jump filterchannel_end; 
filterchannel_fir: 
	call fir(DB); 
	nop;
	nop;
filterchannel_end:
	rts; 
