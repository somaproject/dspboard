/*===================================================================
   SOMA DSPboard DSP code
   
====================================================================*/
#include <def21262.h>
#include <memory.h>

.SECTION/PM seg_rth;
	nop; 
	nop; 
	nop; 
	nop;
	nop;  
	jump main; 



.SECTION/PM seg_pmda;

	// FILTERS
	.VAR 	SH12[2*SHSIZE]; // interleaved filter coeff for channels 1 & 2
	.VAR 	SH34[2*SHSIZE]; // interleaved filter coeff for channels 3 & 4
	.VAR 	COH[COHSIZE];	// filter coefficients for continuous channel

	.VAR 	SY1[SYSIZE];   	// spike channel 1 output circular buffer
	.VAR 	SY2[SYSIZE];   	// spike channel 2 output circular buffer   
	.VAR 	SY3[SYSIZE];   	// spike channel 3 output circular buffer
	.VAR 	SY4[SYSIZE];   	// spike channel 4 output circular buffer
	.VAR 	COY[COYSIZE];	// continuous channel output circular buffer
	.GLOBAL SH12, SH34, COH, SY1, SY2, SY3, SY4, COY;
	
	
.SECTION/DM seg_dm32da;
	.VAR 	TIMESTAMP;  	// current 32-bit timestamp
	.VAR 	MYID;  			// tetrode ID, read from DSP on start-up
	.GLOBAL TIMESTAMP, MYID; 
	
	 
	// spike-specific	
	.VAR 	SPIKELEN; 		// how many samples in a spike
	.VAR 	POSTTRIGLEN; 	// how far back to look for a threshold cross
	.VAR 	NOTRIGGERLEN; 	// how long after a trigger to not trigger
	.VAR 	NOTRIGGER;  	// the actual trigger countdown
	.GLOBAL SPIKELEN, POSTTRIGLEN, NOTRIGGERLEN, NOTRIGGER;
	
	// spike data channels
	.VAR 	CURRENTPOS; 	// current position in the spike channes;
	.VAR 	SX12[SXSIZE]; 	// interleaved input circular buff for ch 1 & 2
	.VAR 	SX34[SXSIZE]; 	// interleaved input circular buff for ch 3 & 4
	.GLOBAL CURRENTPOS, SX12, SX34; 
	 
	// spike channel configuration
	.VAR 	SGAIN[4];
	.VAR 	SFID[4];
	.VAR 	SHFID[4];
	.VAR 	STHRESH[4];
	.VAR    SHLEN[4];
	.GLOBAL SGAIN, SFID, SHFID, STHRESH, SHLEN;  
	
	// continuous-specific variables
	.VAR 	CODOWNSAMPLE;   // downsample ratio
	.VAR 	COX[COXSIZE]; 	// direct circular buffer for continuous channel
	.VAR 	COGAIN;			// GAIN of continuous channel
	.VAR 	COCHAN;			// which channel is this continuous channel sampling
	.VAR 	COFID;			// ID of continuous FIR filter
	.VAR 	COHFID; 		// ID of continuous hardware filter
	.VAR    COHLEN;			// length of continuous filter
	.VAR    CONTLEN; 		// how many downsampled-samples of eeg we output; 
 	.VAR 	CONTCNT; 		// countdown until we send a packet; 
 	.GLOBAL CODOWNSAMPLE, COX, COGAIN, COCHAN, COFID, COHFID, COHLEN,
 			CONTLEN, CONTCNT; 
	 	
	.VAR 	PENDINGOUTSPIKE;	// is there a pending out spike packet? 
	.VAR 	PENDINGOUTCONT; 	// is there a pending out continuous packet
	.GLOBAL PENDINGOUTSPIKE, PENDINGOUTCONT; 
	// acqboard-related
	.VAR	CMDID;
	.VAR 	CMDIDPENDING; 
	
	// event status
	.VAR    EVENTIN[6];
	.VAR    EVENTDONE;
	.VAR 	EVENTOUT[5]; 
	
	.GLOBAL EVENTIN, EVENTOUT, MYID;
		.VAR	OUTSPIKE2[OUTSPIKELEN]; // space to assemble the output spike; 
	
.SECTION/DM seg_dm16da; 

	.VAR	OUTSPIKE[OUTSPIKELEN]; // space to assemble the output spike; 
	.VAR    INSTATUS; 
	.VAR 	NEWSAMPLES[5]; 	// new input samples
	.GLOBAL OUTSPIKE, NEWSAMPLES; 
	

	.VAR 	OUTCONT[OUTCONTLEN]; // output space for continuous
		
	

.SECTION/PM seg_pmco; 

lock_mem:
	bit set imask IRQ0I;
	rts; 

unlock_mem:
	bit clr	imask IRQ0I; 
	rts; 
	


main: 
	r9 =0;
mainl:	
	// test dma
	r9 = r9+1; 

	r0 = 0xD000;
	r0 = r0 + r9;  
	dm(OUTSPIKE) = r0;
	
	r0 = 0; 
	r1 = OUTSPIKE; 
	r1 = r1 + 1;
	 
	
	lcntr = 0xD0, do mainloop until lce; 
		i0 = r1; 
		dm(0,i0) = r0; 
		r0 = r0 + 1;
		r1 = r1 + 1; 	
	
	mainloop:  nop; 
	r0 = OUTSPIKE;
	
	.extern send_data_packet_dma;
	
	call send_data_packet_dma; 
	

	
	jump mainl; 
	
	
	
	jump dispatch_event; 
	
	
init :  

	bit set mode1 CBUFEN; // enable circular buffers
	// make sure we're using the right register set
	
	bit clr mode1 SRCU | SRRFH | SRRFL | SRD1H | SRD1L | SRD2H | SRD2L;  

	// DAG1[5]: input pointer for Spike chans 1 & 2
	b5 = SX12;
	m5 = 2; 
	i5 = SX12;
	l5 = SXSIZE; 
	
	// DAG1[6]: input pointer for spike chans 3 & 4
	b6 = SX34;
	m6 = 2; 
	i6 = SX34;
	l6 = SXSIZE; 

	// DAG1[7]: Input pointer for Continuous	
	b7 = COX;
	m7 = 1; 
	i7 = COX;
	l7 = COXSIZE; 
	
	// DAG2[3]: output pointer for continuous
	b11 = COY;
	m11 = 1; 
	i11 = COY;
	l11 = COYSIZE; 
	
	// DAG2[4]: output pointer for spike chan 1
	b12 = SY1; 
	m12 = 1; 
	i12 = SY1;
	l12 = SYSIZE;
	
	// DAG2[5]: output pointer for spike chan 2
	b13 = SY2; 
	m13 = 1; 
	i13 = SY2;
	l13 = SYSIZE; 
	
	// DAG2[6]: output pointer for spike chan 3
	b14 = SY3; 
	m14 = 1; 
	i14 = SY3;
	l14 = SYSIZE; 
	
	// DAG2[7]: output pointer for spike chan 4
	b15 = SY4; 
	m15 = 1; 
	i15 = SY4;
	l15 = SYSIZE; 
	
	// configure FLAG inputs
	FLAGS = 0x00 ; //all inputs!
	ustat1 = dm(SYSCTL); 
	bit set ustat1 IRQ0EN | IRQ1EN; 
	dm(SYSCTL) = ustat1; 
	
	bit set mode2 IRQ0E | IRQ1E; // IRQ0 and IRQ1 are edge-sensitive
	
	
	
		
	call setup_data; // debugging!! 	
	
	
sample_loop:
	//call	samples;
	call 	sd_newsamples; 
	 
	jump sample_loop; 
	
	
	
	
/* -------------------------------------------------------
	dma_read : reads in r0 32-bit packed words from external
			   address r1 to location pointed to by r2; 
			   
----------------------------------------------------------*/ 


	
	 
	
setup_data:
    // test code to setup vectors for testing things. 
    // filter lengths
    
    
 	r0 = 16; 
	dm(POSTTRIGLEN) = r0;     
	r0 = 32; 
	dm(SPIKELEN) = r0 ; 
	r0 = 32;
	dm(NOTRIGGERLEN) = r0 ; 
    m8 = 1;    
    f0 = 0.0;
    f1 = 1.0/32768.0;
    f4 = 1.0/16.0;  
    /*
    lcntr = 32, do sd_sy until lce; 
		f2 = f0 * f1;
		f5 = f2 + f4; 
		f3 = 2.0; 
		pm(i12, m8) = f5; 
		f2 = f2 * f3; 
		f5 = f2 + f4;
		pm(i13, m8) = f5; 
		f2 = f2 * f3; 
		f5 = f2 + f4; 
		pm(i14, m8) = f5; 
		f2 = f2 * f3; 
		f5 = f2 + f4; 
		pm(i15, m8) = f5; 
		f3 = 1.0;
    	
    
    sd_sy: f0 = f0 + f3;   */
    
    
    r0 = 0x89ABCDEF; 
    dm(TIMESTAMP) = r0; 
    
    r0 = 0x32; // my ID
    dm(MYID) = r0; 
    
    // other settings
	r0 = 0; 
   	f2 = -10000.0; 

    lcntr = 4, do sd_spikeothers until lce;
    	m0 = r0;  
    	i0 = SGAIN;
    	r1 = 100;  
    	dm(m0, i0) = r1; 
    	
    	i0 = SFID;
    	r1 = 0x1234;
    	dm(m0, i0) = r1; 
    	
    	i0 = SHFID; 
    	r1 = 0xC; 
    	dm(m0, i0) = r1; 
    	
    	i0 = STHRESH;
    	dm(m0, i0) = f2; 
		f3 = 2.0;
		f2 = f2 * f3; 		    	
    	
    	i0 = SHLEN;
    	r1 = 100; 
    	dm(m0, i0) = r1; 
    	
    	
	sd_spikeothers: r0 = r0 + 1; 
	
    r0 = 100; 
	dm(COHLEN) = r0;    
	
	
	// setup filters to be impulses, scaled
	// 
	b8 = SH12; 
	b9 = SH34; 
	m8 = 1;
	f0 = 0.0;  
	pm(i8, m8) = 1.0; 
	pm(i8, m8) = 1.0; 
	pm(i9, m8) = 1.0;
	pm(i9, m8) = 1.0; 
	
	lcntr = SHSIZE * 2 - 2 , do sd_clrh until lce; 
		pm(i8, m8) = f0; 
		pm(i9, m8) = f0; 
	sd_clrh: nop;

sd_newsamples:	
	r0 = dm(NEWSAMPLES); 
	r0 = r0 + 1; 
	
	dm(NEWSAMPLES) = r0;
	r1 = lshift r0 by 1;  
	dm(NEWSAMPLES + 1) = r1; 
	r1 = lshift r1 by 1;  
	dm(NEWSAMPLES + 2) = r1; 
	r1 = lshift r1 by 1;  
	dm(NEWSAMPLES + 3) = r1; 
	r1 = lshift r1 by 1;  
	dm(NEWSAMPLES + 4) = r1; 
	
    rts; 

    

/*--------------------------------------------------
  dispatch_event: main event loop
  calls read_event
  
  NO EVENT PROCESSING DONE HERE! Rather, jump to event_foo
  
  event_foo should jump back to dispatch_event_end
  
  
  
  
  -------------------------------------------------*/
dispatch_event: 

	call read_event; 
	
	r0 = 0x40; 
	COMP(r0, r11);
	if EQ jump event_write; 
	
	r0 = 0x41; 
	COMP(r0, r11); 
	if EQ jump event_read; 
	
	r0 = 0x44;
	COMP(r0, r11);
	if EQ jump event_acqboard_set; 
   
 
dispatch_event_end:
// done with event
/*---------------------------------------------------
  read_event:
     returns a read-event from FPGA:
     r11 = command byte 
     r12 = sender
     r13 = data word 0 
     r14 = data word 2 | data word 1
     r15 = data word 4 | data word 3;
---------------------------------------------------*/

read_event:
	call	lock_mem; 
	ustat3 = PPDUR10 | PPBHC | PP16 | PPEN | PPDEN;
	ustat4 = PPDUR10 | PPBHC | PP16; 
	
	dm(PPCTL) = ustat4; 
	
	r0 = EVENTIN; 		dm(IIPP) = r0; 	// starting point
	r0 = 1;				dm(IMPP) = r0; 

	r0 = 4;				dm(ICPP) = r0; 
	r0 = 1; 			dm(EMPP) = r0; 
	r0 = FPGA_EVENTRD;	dm(EIPP) = r0; 
	r0 = 8;				dm(ECPP) = r0; 

	
	
	dm(PPCTL) = ustat3; 
	
	nop;
	nop;
read_event_wait:
	ustat4 = dm(PPCTL); 
	bit tst ustat4 PPDS;  // poll for dma status 
	if tf jump read_event_wait; 
	
	r0 = dm(EVENTIN); 
	r11 = FEXT r0 BY 0:8;
	r12 = FEXT r0 BY 8:8;
	r13 = FEXT r0 BY 16:16;
	r14 = dm(EVENTIN+1);
	r15 = dm(EVENTIN+2); 
	call	unlock_mem; 
	
	rts; 


/*---------------------------------------------------
  write_event:
     writes an event to the event bus:
     r0 =  address bits 31:0
     r1 =  address bits 47:32 (in LSBs)
     r2 =  command (8 lower bits)
     r3 =  data word 1
     r4 =  dw 3 | 2
     r5 = dw 5 | 4; 
     
---------------------------------------------------*/

write_event:
	call	lock_mem; 
	
	// debugging;
	dm(EVENTOUT) = r0; // first two address words verbatim
	r0 = fext r1 by 0:16;  // r0 has last address word as lsw
	r0 = r0 or fdep r2 by 16:8; // put in the command
	r2 = dm(MYID); 	         
	r0 = r0 or fdep r2 by 24:8; // put my ID in there
	dm(EVENTOUT+1) = r0; 
	// assemble next three words; 
	r3 = r3 or fdep r4 by 16:16; 
    dm(EVENTOUT+2) = r3; 
	
    r4 = fext r4 by 16:16; 
    r4 = r4 or fdep r5 by 16:16;
	dm(EVENTOUT+3) = r4;
	
	r5 = fext r5 by 16:16; 
	dm(EVENTOUT+4) = r5; 
	 
	
	 
	
	ustat3 = PPDUR16 | PPTRAN | PPBHC | PP16 | PPEN | PPDEN;
	ustat4 = PPDUR16 | PPTRAN | PPBHC | PP16; 
	
	dm(PPCTL) = ustat4; 
	
	r0 = EVENTOUT; 	dm(IIPP) = r0; 	// starting point
	r0 = 1;			dm(IMPP) = r0; 

	r0 = 5;			dm(ICPP) = r0; 
	r0 = 1; 		dm(EMPP) = r0; 
	r0 = FPGA_EVENTWR;	dm(EIPP) = r0; 
	r0 = 10;		dm(ECPP) = r0; 

	
	
	nop;
	nop;
	
	dm(PPCTL) = ustat3; 
write_event_wait:
	ustat4 = dm(PPCTL); 
	bit tst ustat4 PPDS;  // poll for dma status 
	if tf jump write_event_wait; 
	
	
	call	unlock_mem; 
	
	rts; 

		
/*-------------------------------------------------  
event_write: takes in standard event registers
     extracts TARGET, that is, what we're writing
     and ADDR, which is in most cases the address
     of a buffer, etc. 
--------------------------------------------------*/

event_write:
    r0 = FEXT r13 BY 8:8; // RO is target
    r1 = FEXT r13 by 0:8; // R1 is address
    

// check for FIR filter coefficient writing:
	r2 = 0x10;
	COMP(r2, r0);
	IF EQ JUMP event_write_spike_fir_1;

	r2 = 0x11;
	COMP(r2, r0);
	IF EQ JUMP event_write_spike_fir_2;
	
	r2 = 0x12;
	COMP(r2, r0);
	IF EQ JUMP event_write_spike_fir_3;
	
	r2 = 0x13;
	COMP(r2, r0);
	IF EQ JUMP event_write_spike_fir_4;

	r2 = 0x14;
	COMP(r2, r0);
	IF EQ JUMP event_write_cont_fir;
	
// filter lengths
	r2 = 0x20; 
	COMP(r2, r0);
	IF EQ JUMP event_write_filterlen; 
	
// filter IDs
	r2 = 0x21; 
	COMP(r2, r0);
	IF EQ JUMP event_write_filterID; 
	
// spike parameters
	r2 = 0x23; 
	COMP(r2, r0);
	IF EQ JUMP event_write_spikelen; 
	
	r2 = 0x24; 
	COMP(r2, r0);
	IF EQ JUMP event_write_notriggerlen; 
	
	r2 = 0x25; 
	COMP(r2, r0);
	IF EQ JUMP event_write_posttriglen; 

// continuous channel parameters
	r2 = 0x26; 
	COMP(r2, r0);
	IF EQ JUMP event_write_downsample;
	
	r2 = 0x27; 
	COMP(r2, r0);
	IF EQ JUMP event_write_contlen; 
	
	
 
	
	
	
event_write_spike_fir_1:
	r5 = dm(SHLEN);
	r4 = 2; 
	r4 = r5 - r4;  // make sure we're not trying to write too far
	COMP(r4, r1); 
	if LT jump event_write_error;  
	
	i8 = SH12;
	r3 = LSHIFT R1 by 1; 			// multiply by two 
	r3 = r3 + 1, m8 = r3; 			// inc r3 to point to h2[n]
	r3 = r3 + 1, pm(m8, i8) = r14;  // inc r3 to point to h1[n+1]
									// store DW0 in h1[n];  
	m8 = r3; 
	pm(m8, i8) = r15; 				// store DW1 in h1[n+1]; 
	
	jump event_write_end; 

event_write_spike_fir_2:
	r5 = dm(SHLEN);
	r4 = 2; 
	r4 = r5 - r4;  // make sure we're not trying to write too far
	COMP(r4, r1); 
	if LT jump event_write_error;  
	
	i8 = SH12;
	r3 = LSHIFT R1 by 1; 			// multiply by two 
	r3 = r3 + 1; 					// the H2s are one-off
	r3 = r3 + 1, m8 = r3; 			// inc r3 to point to h1[n+1]
	r3 = r3 + 1, pm(m8, i8) = r14;  // inc r3 to point to h2[n]
									// store DW0 in h2[n]; 
	m8 = r3; 
	pm(m8, i8) = r15; 				// store DW1 in h2[n+1]; 
	
	jump event_write_end; 
	
event_write_spike_fir_3:
	r5 = dm(SHLEN);
	r4 = 2; 
	r4 = r5 - r4;  // make sure we're not trying to write too far
	COMP(r4, r1); 
	if LT jump event_write_error;  
	
	i8 = SH34;
	r3 = LSHIFT R1 by 1; 			// multiply by two 
	r3 = r3 + 1, m8 = r3; 			// inc r3 to point to h4[n]
	r3 = r3 + 1, pm(m8, i8) = r14;  // inc r3 to point to h3[n+1]
									// store DW0 in h3[n]; 
	m8 = r3; 
	pm(m8, i8) = r15; 				// store DW1 in h3[n+1]; 
	
	jump event_write_end; 

event_write_spike_fir_4:
	r5 = dm(SHLEN);
	r4 = 2; 
	r4 = r5 - r4;  // make sure we're not trying to write too far
	COMP(r4, r1); 
	if LT jump event_write_error;  
	
	i8 = SH34;
	r3 = LSHIFT R1 by 1; 			// multiply by two 
	r3 = r3 + 1; 					// the H4s are one-off
	r3 = r3 + 1, m8 = r3; 			// inc r3 to point to h3[n+1]
	r3 = r3 + 1, pm(m8, i8) = r14;  // inc r3 to point to h4[n]
									// store DW0 in h4[n]; 
	m8 = r3; 
	pm(m8, i8) = r15; 				// store DW1 in h4[n+1]; 
	
	jump event_write_end; 
	
event_write_cont_fir:
	r5 = dm(COHLEN);
	r4 = 2; 
	r4 = r5 - r4;  // make sure we're not trying to write too far
	COMP(r4, r1); 
	if LT jump event_write_error;  
	
	i8 = COH;
	m8 = r3; 						// m8 = address
	r3 = r3 + 1, pm(m8, i8) = r14;  // inc r3 to point to hc[n+1]
									// store DW0 in h1[n];
	m8 = r3; 								 
	pm(m8, i8) = r15; 				// store DW1 in h1[n+1]; 
	
	jump event_write_end; 
	
event_write_filterlen:
	r4 = 4; 
	COMP(r4, r1);
	if LT jump event_write_error; 
	
	if EQ jump event_write_filterlen_cont;
	
	// spike channel lengths
	i0 = SHLEN; 
	m0 = r1; 
	r4 = FEXT r14 BY 0:8 ; // only get the lower 8 bits of the filter length; 
	dm(m0, i0) = r4; 
	jump event_write_end;

event_write_filterlen_cont:
	r4 = FEXT r14 BY 0:8;
	dm(COHLEN) = r4; 
	jump event_write_end;
	
event_write_filterID:
	r4 = 4; 
	COMP(r4, r1);
	if LT jump event_write_error; 
	
	if EQ jump event_write_filterID_cont;
	
	// spike channel lengths
	i0 = SFID; 
	m0 = r1; 
	r4 = FEXT r14 BY 0:16 ; // only get the lower 16 bits of the filter ID 
	dm(m0, i0) = r4; 
	jump event_write_end;

event_write_filterID_cont:
	r4 = FEXT r14 BY 0:16;
	dm(COFID) = r4; 
	jump event_write_end;
	
event_write_spikelen:
	r4 = FEXT r14 by 0:8; 
	dm(SPIKELEN) = r4; 
	jump event_write_end; 
	
event_write_notriggerlen:
	r4 = FEXT r14 by 0:8; 
	dm(NOTRIGGERLEN) = r4; 
	jump event_write_end; 
	
event_write_posttriglen:
	r4 = FEXT r14 by 0:8; 
	dm(POSTTRIGLEN) = r4; 
	jump event_write_end; 
	
event_write_downsample:
	r4 = FEXT r14 by 0:4; 
	dm(CODOWNSAMPLE) = r4; 
	jump event_write_end; 
	
event_write_contlen:
	r4 = FEXT r14 by 0:8; 
	dm(CONTLEN) = r4; 
	jump event_write_end; 

	
		
event_write_error:
	// some sort of error-related thing here; 
	
	
	
event_write_end:
	jump dispatch_event_end;    

    
    
event_read:
	nop;
    
/*---------------------------------------------------------------
  event_acqboard_set:
     sets acqboard properties, using a format similar
     to the standard register set. 
     
     However, this is an asynchronous event. If there is a pending
     event, calling an event like this will trigger an
     E_ACQBOARD_PENDING error : )
---------------------------------------------------------------*/

event_acqboard_set:
    r0 = FEXT r13 BY 8:8; // RO is target
    r1 = FEXT r13 by 0:8; // R1 is address
    
    r2 = dm(CMDIDPENDING);    // CMDIDPENDING < 0 => there is a pending command
    						  // thus we signal an error!!!
    r3 =0; 						  
    COMP(r2, r3); 
    if LT jump event_acqboard_set_error;

      
	r2 = 0x00;
	COMP(r2, r0);
	IF EQ JUMP event_acqboard_set_gain;
	
	r2 = 0x01;
	COMP(r2, r0);
	IF EQ JUMP event_acqboard_set_gain;
	
	r2 = 0x02;
	COMP(r2, r0);
	IF EQ JUMP event_acqboard_set_gain;
	

	jump event_acqboard_set_end; 
	
event_acqboard_set_gain:



event_acqboard_set_hwfilter:

event_acqboard_set_continput:

	
event_acqboard_set_send:   // actually send the event via DMA

	r2 = dm(CMDID);  // inc cmd pending
	r2 = r2 + 1; 

	// update CMDIDPENDING
	
	//update 
	
	dm(CMDIDPENDING) = r2; 
	

    
event_acqboard_set_error:


event_acqboard_set_end: 

	rts; 
    

