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
	.VAR	SAMPLING;		// is the SAMPLE interrupt enabled. 
	.GLOBAL TIMESTAMP, MYID, SAMPLING; 
	
	 
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
	.VAR 	LINKSTAT; 
	.VAR 	CMDPENDING; 
	.VAR	NEWSTAT;
	.global CMDID, CMDIDPENDING, CMDPENDING, LINKSTAT, NEWSTAT;  
	
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

.global lock_ppdma, unlock_ppdma; 
lock_ppdma: 
	bit set imask IRQ0I;
	rts; 
lock_ppdma.end:

unlock_ppdma:
	bit clr	imask IRQ0I; 
	rts; 
unlock_ppdma.end:	


main: 
	r9 =0;
mainl:	
	// test dma
	
	r0 = 0x00020003; dm(CMDPENDING) = r0; 
	r0 = 0x00000100; dm(CMDPENDING+1) = r0;
	call update_from_cmdpending; 

	r0 = 0x00020003; dm(CMDPENDING) = r0; 
	r0 = 0x00000205; dm(CMDPENDING+1) = r0;
	call update_from_cmdpending; 
	
	
	r0 = 0x00020003; dm(CMDPENDING) = r0; 
	r0 = 0x00000307; dm(CMDPENDING+1) = r0;
	call update_from_cmdpending; 

	
	r0 = 0x00020003; dm(CMDPENDING) = r0; 
	r0 = 0x00000409; dm(CMDPENDING+1) = r0;
	
	call update_from_cmdpending; 
	r0 = 0x00020002; dm(CMDPENDING) = r0; 
	r0 = 0x00000209; dm(CMDPENDING+1) = r0;
			
	jump mainl; 
	
	
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
	
	
	
	//jump dispatch_event; 
	
	
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

    
