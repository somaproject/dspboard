/*===================================================================
   SOMA DSPboard DSP code
   
====================================================================*/
#include <def21262.h>

.SECTION/PM seg_rth;
	nop; 
	nop; 
	nop; 
	nop;
	nop;  
	jump main; 

#define SXSIZE 256 
#define SHSIZE 256
#define SYSIZE 256
#define COXSIZE 1024
#define COHSIZE 256
#define COYSIZE 256
	
.SECTION/PM seg_pmda;
	// FILTERS
	.VAR 	SH12[2*SHSIZE]; 		// interleaved filter coeff for channels 1 & 2
	.VAR 	SH34[2*SHSIZE]; 		// interleaved filter coeff for channels 3 & 4
	.VAR 	COH[COHSIZE];	  	 	// filter coefficients for continuous channel
	
	
.SECTION/DM seg_dm32da;
	.VAR 	TIMESTAMP;  	// current 32-bit timestamp
	.VAR 	TETRODEID;  	// tetrode ID, read from DSP on start-up
	.VAR 	NEWSAMPLES[5]; 	// new input samples
	
	// spike-specific	
	.VAR 	SPIKELEN; 		// how many samples in a spike
	.VAR 	POSTTRIGLEN; 	// how far back to look for a threshold cross
	.VAR 	NOTRIGGERLEN; 	// how long after a trigger to not trigger
	.VAR 	NOTRIGGER;  	// the actual trigger countdown
	 
	// spike data channels
	.VAR 	CURRENTPOS; 	// current position in the spike channes;
	.VAR 	SX12[SXSIZE]; 	// interleaved input circular buff for ch 1 & 2
	.VAR 	SX34[SXSIZE]; 	// interleaved input circular buff for ch 3 & 4
	 
	// spike channel configuration
	.var 	SGAIN[4];
	.var 	SFID[4];
	.var 	SHFID[4];
	.var 	STHRESH[4];
	
	// continuous-specific variables
	.VAR 	CODOWNSAMPLE;
	.VAR 	COX[COXSIZE]; 	// direct circular buffer for continuous channel
	.VAR 	COGAIN;
	.VAR 	COFID;
	.VAR 	COHFID; 
	 	

.SECTION/DM seg_dm16da; 

	 .VAR SY1[SYSIZE];   // 16-bit spike channel 1 output circular buffer
	 .VAR SY2[SYSIZE];   // 16-bit spike channel 2 output circular buffer   
	 .VAR SY3[SYSIZE];   // 16-bit spike channel 3 output circular buffer
	 .VAR SY4[SYSIZE];   // 16-bit spike channel 4 output circular buffer  
	

.SECTION/PM seg_pmco; 

main: 
	nop;
	nop; 
	R0 = 0x1000;
	nop;
	nop;
	jump	init;
	
	
init :  

	// DAG1[5]: input pointer for Spike chans 1 & 2
	b5 = SX12;
	m5 = 2; 
	i5 = SX12;
	l5 = SXSIZE; 
	
	// DAG1[6]: input pointer for spike chans 3 & 4
	b6 = SX34;
	m6 = 2; 
	i6 = SX12;
	l6 = SXSIZE; 

	// DAG1[7]: Input pointer for Continuous	
	b7 = COX;
	m7 = 2; 
	i7 = COX;
	l7 = COXSIZE; 
	
	
samples:
	// Process inbound samples
	// first, perform DMA, and add them to the end 
	// 
	// update NEWSAMPLES[5]
	
	// check if there was a previously-complete spike, and
	// send it.
	
	// convert new samples to FP and save in circular buffers
		// we store the new sample at location n+1; 
	
	
	
	// perform filtering
	
	// configure for channels 1 & 2
	
	b0 = b5; // base of spike chans 1 & 2
	m0 = -2;  // go backward by 2
	i0 = i5;  // we're at the base
	l0 = l5;  // same length
	
	// configure for filter for channesl 1 & 2
	b8 = SH12;
	m8 = 2; // incrememnt by 2!
	i8 = SH12;
	l8 = SHSIZE;
	
	
	bit set mode1 PEYEN | CBUFEN; // enable circular buffering and
								 // secondary computation unit
	//bit set mode1 BDCST1 | BDCST9; // enable broadcast loading
	
	nop;
	nop;
	// begin the pipelining
	f0=dm(i0,m0), f4=pm(i8,m8); // get first x, h, 
	f12=f0*f4, f0=dm(i0,m0), f4=pm(i8,m8); // perfrom mult, get next
	
	lcntr=10, do macs until lce; 
		  	
    // p[n-1]=x[n-1]*h[n-1], s[n-3]=s[n-3]+p[n-2],  get x[n], get h[n]
	macs: f12=f0*f4, f8=f8+f12, f0=dm(i0,m0), f4=pm(i8,m8); 
	
	f12=f0*f4, f8=f8+f12; 
	
	f8=f8+f12; 
	      	  
	
