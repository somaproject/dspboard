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

#define SXSIZE 300 
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

	.VAR 	SY1[SYSIZE];   			// spike channel 1 output circular buffer
	.VAR 	SY2[SYSIZE];   			// spike channel 2 output circular buffer   
	.VAR 	SY3[SYSIZE];   			// spike channel 3 output circular buffer
	.VAR 	SY4[SYSIZE];   			// spike channel 4 output circular buffer
	.VAR 	COY[COYSIZE];			// continuous channel output circular buffer
  	
	
.SECTION/DM seg_dm32da;
	.VAR 	TIMESTAMP;  	// current 32-bit timestamp
	.VAR 	MYID;  	// tetrode ID, read from DSP on start-up
	
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
	.VAR 	SGAIN[4];
	.VAR 	SFID[4];
	.VAR 	SHFID[4];
	.VAR 	STHRESH[4];
	.VAR    SHLEN[4]; 
	
	// continuous-specific variables
	.VAR 	CODOWNSAMPLE;
	.VAR 	COX[COXSIZE]; 	// direct circular buffer for continuous channel
	.VAR 	COGAIN;
	.VAR 	COFID;
	.VAR 	COHFID; 
	.VAR    COHLEN; 
	 	

.SECTION/DM seg_dm16da; 
#define OUTSPIKELEN 300

	.VAR	OUTSPIKE[OUTSPIKELEN]; // space to assemble the output spike; 
	.VAR 	NEWSAMPLES[5]; 	// new input samples
	
	

.SECTION/PM seg_pmco; 

main: 
	nop;
	nop; 
	R0 = 0x0;
	nop;
	nop;
	r0 = 32767; 
	r1 = -32768; 
	r2 = -15; 
	r6 = 15; 
	
	f3 = FLOAT r1 BY r2;
	f4 = FLOAT r0 BY r2; 
	r7 = -1; 
	f5 = FLOAT r7 BY r2; 
	
	r8 = FIX f3 by r6;
	r9 = FIX f4 by r6; 
	r10 = FIX f5 by r6;
	
	
init :  
	bit set mode1 CBUFEN; 
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
	
		
	call setup_data; // debugging!! 	
	
	
sample_loop:
	call	samples;
	call 	sd_newsamples; 
	 
	jump sample_loop; 
	
	
	
samples:
// Process inbound samples
// first, perform DMA, and add them to the end 
// 
// update NEWSAMPLES[5]

// check if there was a previously-complete spike, and
// send it.

// convert new samples to FP and save in circular buffers
	// we store the new sample at location n+1; 

	i0 = NEWSAMPLES; 
	m0 = 1; 
	r1 = -15; 
	
	r0 = dm(0x0, i0); // sample for channel 1;
	f2 = FLOAT r0 by r1; 
	dm(i5, m0) = f2; 

	r0 = dm(0x1, i0); // sample for channel 2;
	f2 = FLOAT r0 by r1; 
	dm(i5, m0) = f2; 
	 
	
	r0 = dm(0x2, i0); // sample for channel 3;
	f2 = FLOAT r0 by r1; 
	dm(i6, m0) = f2; 

	r0 = dm(0x3, i0); // sample for channel 4;
	f2 = FLOAT r0 by r1; 
	dm(i6, m0) = f2; 
	 
	r0 = dm(0x4, i0); // sample for channel C;
	f2 = FLOAT r0 by r1; 
	dm(i7, m0) = f2; 
	 

// perform filtering
	
	// configure for channels 1 & 2
	i0 = SHLEN; 
	r0 = dm(0x0, i0); // get SHLEN[0]
	r1 = dm(0x1, i0); // get SHELN[1]
	
	r0 = max(r0, r1); // length of filter is max of the two 
	
		
	b0 = b5; // base of spike chans 1 & 2
	m0 = -2;  // go backward by 2
	r2 = i5;   // since we just added a sample, we want to step 
	r3 = 2;   // backwards one sample
	r2 = r2 - r3; 
	i0 = r2;  
	l0 = l5;  // same length
	
	// configure for filter for channesl 1 & 2
	b8 = SH12;
	m8 = 2; // incrememnt by 2, i.e. interleaved
	i8 = SH12;
	l8 = dm(SHSIZE);
	
	call filter_fir_simd; 
	
	pm(i12, m12) = f0;	// save result from spike 1
	pm(i13, m13) = f1;  // save result from spike 2
	
	
	// configure for channels 3 & 4
	i0 = SHLEN; 
	r0 = dm(0x2, i0); // get SHLEN[2]
	r1 = dm(0x3, i0); // get SHELN[3]
	
	r0 = max(r0, r1); 	
		
	b0 = b6; // base of spike chans 3 & 4
	m0 = -2;  // go backward by 2
	r2 = i6;   // since we just added a sample, we want to step 
	r3 = 2;   // backwards one sample
	r2 = r2 - r3; 
	i0 = r2;  
	l0 = l6;  // same length
	
	// configure for filter for channesl 3 & 4
	b8 = SH34;
	m8 = 2; // incrememnt by 2. i.e. interleaved
	i8 = SH34;
	l8 = dm(SHSIZE);
	

	
	call filter_fir_simd; 
	
	pm(i14, m14) = f0;	// save result from spike 3
	pm(i15, m15) = f1;  // save result from spike 4
	
	
	// configure for continuous channel
	
	b0 = b7; // base of continuous channel
	m0 = -1;  // go backward by 1
	i0 = i7;  // we're at the base
	l0 = l7;  // same length
	
	// configure for filter for continuous channel
	b8 = COH;
	m8 = 1; // incrememnt by 1
	i8 = COH;
	l8 = COHSIZE;
	
	r0 = dm(COHLEN); // length of filter
	call filter_fir; 
	
	pm(i11, m11) = f0;	// save result from continuous

// check for thresholds
samples_threshold:
    // this is a whee-bit ghetto because we need to manually
    // figure out what the address for POSTTRIGLEN is:

    r0 = dm(NOTRIGGER);
    r0 = r0 - 1; 
    dm(NOTRIGGER) = r0; 
    
    if GT jump samples_threshold_done; // we're still in a no-trigger phase
    
       
    r0 = dm(POSTTRIGLEN); 
 	i0 = STHRESH; 
  	
 	// channel 1 threshold check 
  	r1 = i12; 			// chan 1 index
  	r2 = b12; 
  	r4 = l12; 
  	r3 = r1 - r0;		// r3 = position back the necessary samples
  	r5 = r3 - r2;  		// R5 = location back - base 
  	if LT r3 = r3 + r4; // if we went past the end of the buffer
	i8 = r3; 
  	f1 = pm(0, i8);		// read the sample POSTTRIGLEN back
  	 
  	f2 = dm(0, i0); 	// get the threshold
  	f2 = f1 - f2; 
  	if GE jump samples_send_spike; 
 
 	// channel 2 threshold check 
  	r1 = i13; 			// chan 2 index
  	r2 = b13; 
  	r4 = l13; 
  	r3 = r1 - r0;		// r3 = position back the necessary samples
  	r5 = r3 - r2;  		// R5 = location back - base 
  	if LT r3 = r3 + r4; // if we went past the end of the buffer
	i8 = r3; 
  	f1 = pm(0, i8);		// read the sample POSTTRIGLEN back
  	 
  	f2 = dm(1, i0); 	// get the threshold
  	f2 = f1 - f2; 
  	if GE jump samples_send_spike; 

  	// channel 3 threshold check 
  	r1 = i14; 			// chan 3 index
  	r2 = b14; 
  	r4 = l14; 
  	r3 = r1 - r0;		// r3 = position back the necessary samples
  	r5 = r3 - r2;  		// R5 = location back - base 
  	if LT r3 = r3 + r4; // if we went past the end of the buffer
	i8 = r3; 
  	f1 = pm(0, i8);		// read the sample POSTTRIGLEN back
  	 
  	f2 = dm(0, i0); 	// get the threshold
  	f2 = f1 - f2; 
  	if GE jump samples_send_spike; 
 	
 	// channel 4 threshold check 
  	r1 = i15; 			// chan 4 index
  	r2 = b15; 
  	r4 = l15; 
  	r3 = r1 - r0;		// r3 = position back the necessary samples
  	r5 = r3 - r2;  		// R5 = location back - base 
  	if LT r3 = r3 + r4; // if we went past the end of the buffer
	i8 = r3; 
  	f1 = pm(0, i8);		// read the sample POSTTRIGLEN back
  	 
  	f2 = dm(0, i0); 	// get the threshold
  	f2 = f1 - f2; 
  	if GE jump samples_send_spike; 
	
  	jump samples_threshold_done; 
  
  	  	
samples_send_spike:
	// we have a threshold crossing!
	
	
	r0 = dm(NOTRIGGERLEN);	// reset no-trigger window
	dm(NOTRIGGER) = r0; 
	
	r0 = dm(SPIKELEN);
	
	call create_spike_packet;  
	
samples_threshold_done:
  	
  	
  	
  	
	

	rts; 
	
/*------------------------------------------------------
  filter_fir_simd performs SIMD filtering, with DAGs pointing
  to relevant filters. R0 is length of conv. 
  
  simple, really: just enables secondary computation unit, makes
  sure modifiers are set to 2, then calls normal filter_FIR routine
  
  inputs: 
      DAG1[0]: points to the circular buffer for x[n] coeff
      DAG2[0] points to the coefficient buffer
      
      r0 = length of convolution
      
  outputs: 
      f0 = y[n] for channel A
      f1 = y[n] for channel B
      
  modifies:
      lcntr, f0, f4, f8, f12, and all PEY eq. 
      DAGs as indicated
 -------------------------------------------------------*/

filter_fir_simd:
	bit set mode1 PEYEN; // secondary computation unit enable
								 
	
	f8 = 0.0; 	// clear accumulator registers
	s8 = 0.0; 
    
	call	filter_fir; 
	
	f0 = f8; 
	f1 = s8; 
	
	bit clr mode1 PEYEN; // disable secondary computation unit.  
	
	rts;

/* ------------------------------------------------------
   filter_fir : performs an N (N = r0) tap floating point
   convolution of the buffer pointed to by DAG1[0] and 
   the filter DAG2[0]; 
   
   DAGs are set up ahead of time; this function is ignorant
   as to increment size or circularity
   
   inputs:
   		DAG1[0] : circular buffer of x[n]
   		DAG2[0] : circular buffer of h[n]
   		
   		r0 = length of convolution
   		
   outputs:
        f0 = y[n];
   modifies:
        well, everything; 
--------------------------------------------------------*/


filter_fir:
	r1 = 2; 
	r1 = r0 - r1; // due to pipelining we actually only cycle N-2 times.
	
	f8 = 0.0; 	// clear accumulator register
	
	// begin the pipelining
	f0=dm(i0,m0), f4=pm(i8,m8); // get first x, h, 
	f12=f0*f4, f0=dm(i0,m0), f4=pm(i8,m8); // perfrom mult, get next
	
	
	lcntr=r1, do macs until lce; 
		  	
	// p[n-1]=x[n-1]*h[n-1], s[n-3]=s[n-3]+p[n-2],  get x[n], get h[n]
	macs: f12=f0*f4, f8=f8+f12, f0=dm(i0,m0), f4=pm(i8,m8); 
	
	f12=f0*f4, f8=f8+f12; 
	
	f8=f8+f12; 
	
	f0 = f8; // return result; 
	
	
	rts; 		
	
	
	
/* -----------------------------------------------------
   create_spike_packet: generates a spike packet using
       the current locations of the SY[n] pointers and
       r0, the number of samples back to use. 
       
       uses current timestamp, i.e. TS is for the _end_
       of the packet. 
       
       creates with all 4 channels, using current gain
       etc. settings
       
       // inputs:
       r0 == the length of a spike, i.e. look back and
             capture r0 points
       
------------------------------------------------------*/

create_spike_packet:
	bit set mode1 CBUFEN; 
	i0 = OUTSPIKE; // set up base
	m0 = 1; 
	b0 = OUTSPIKE; 
	
// create length & ID word
	// each channel has 4 words of header
	r3 = 4; 
	r3 = r0 + r3; 
	r3 = LSHIFT r3 by 2;  // we have 4 chan * (length + fixed stuff)
	r2 = 4;
	r3 = r3 + r2; // plus 4 header words
	
	
	
	r1 = dm(MYID);	// MYID is in lower 8 bits
	r1 = r1 OR FDEP R3 BY 8:8;  // R3 in 8 MSBs!	
	
	dm(i0, m0) = r1 ; // store LENGTH && MYID
	
// number of channels
	dm(i0, m0) = 4; 

// timestamp
	r1 = dm(TIMESTAMP);
	r2 = FEXT r1 by 0:16; 
	dm(i0, m0) = r2;
	r2 = FEXT r1 by 16:16;
	dm(i0, m0) = r2;  
	

// Now we copy channels 1-4
	
	// channel 1:
	b8 = b12;
	i8 = i12; 
	l8 = l12;  // 
	r1 = 0;  	// channel number
	
	call create_spike_packet_channel_data; 

	// channel 2
	b8 = b13;
	i8 = i13; 
	l8 = l13;  // 
	r1 = 1;  	// channel number
	
	call create_spike_packet_channel_data; 

	// channel 3
	b8 = b14;
	i8 = i14; 
	l8 = l14; 
	r1 = 2;  	// channel number
	
	call create_spike_packet_channel_data; 

	// channel 4
	b8 = b15;
	i8 = i15;
	l8 = l15;  // 
	r1 = 3;  	// channel number
	
	call create_spike_packet_channel_data; 

	
	rts; 
	
	
	
/*----------------------------------------------------------------
  create_spike_packet_channel_data
  	Takes in a pointer to a non-interleaved output buffer via DAG2[0]
  	and the current location in DM where you wish to copy the relevant
  	channel location (nomally some place in OUTSPIKE) pointed to 
  	by DAG1[0], and formats the necesasry data. 
  	
  	Accesses various channel-dependent data structures, thus:
  	   r0 = number of samples of output buffer to transfer
  	   r1 = channel number; 
  	
------------------------------------------------------------------*/

create_spike_packet_channel_data:	
// channel configuration
	// r0 = length
	// r1 = current channel
	// DAG2[0] : points to current output buffer
	// DAG1[0] : points to spike output buffer current location
	
	m1 = r1; 	// save chan number
	i1 = SGAIN; 
	r3 = r1; 
	r2 = dm(m1, i1); // gain for current chan; 
	r3 = r3 OR FDEP r2 BY 8:8; 
	dm(i0, m0) = r3; 
	
	// filter id
	i1 = SFID; 
	r2 = dm(m1, i1); 
	dm(i0, m0) = r2;
	
	// hardware filter setting
	i1 = SHFID; 
	r2 = dm(m1, i1); 
	dm(i0, m0) = r2; 
	
	// threshold!!!
	i1 = STHRESH;
	r3 = 15; 
	f2 = dm(m1, i1);
	r2 = FIX f2 by r3;  
	dm(i0, m0) = r2; 
	
	
// actual data;

	// reading in the data is a challenge; we position 
	// DAG2[0] is pointing at the output buffer in PM memory, and
	//    starts off pointing at the next empty spot for a sample
	
	// we set m8 so we can go back to the most recently written sample:
	m8 = -1;
	
	r1 = pm(i8, m8); 	// dummy read to position pointer back to most recen
						// sample

	// set up DAG1[1] to point to end of this channel's segment of the
	// outspike buffer, and step backwards
	 
	b1 = b0; 
	m1 = -1; 
	l1 = OUTSPIKELEN;
	
	// i0 currently points to next empty spot to be filled
	// our index starts out pointing SPIKELEN bits in the future, -1
	r1 = i0; 
	r1 = r1 - 1;  
	r1 = r1 + r0; // r1 = current outbuf point + num spikes
	i1 = r1; 
		
	r4 = 15;  // conversion factor
	
	f3 = pm(i8, m8); // start the pipeline
	lcntr = r0, do spike_write_data until lce; 
		// we simultaneously get the next sample AND convert
		// the current sample
		r2 = FIX f3 by r4, f3 = pm(i8, m8);   
	spike_write_data: dm(i1, m1) = r2;
	// now, we need to update i1; 
	
	r2 = i0; 
	r2 = r2 + r0;
	i0 = r2; // update pointer to point to end of frame; 
	 
	rts;
	
	
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
