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
#define COYSIZE 1024
	
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
  	
	
.SECTION/DM seg_dm32da;
	.VAR 	TIMESTAMP;  	// current 32-bit timestamp
	.VAR 	MYID;  			// tetrode ID, read from DSP on start-up
	
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
	.VAR 	CODOWNSAMPLE;   // downsample ratio
	.VAR 	COX[COXSIZE]; 	// direct circular buffer for continuous channel
	.VAR 	COGAIN;			// GAIN of continuous channel
	.VAR 	COCHAN;			// which channel is this continuous channel sampling
	.VAR 	COFID;			// ID of continuous FIR filter
	.VAR 	COHFID; 		// ID of continuous hardware filter
	.VAR    COHLEN;			// length of continuous filter
	.VAR    CONTLEN; 		// how many downsampled-samples of eeg we output; 
 	.VAR 	CONTCNT; 		// countdown until we send a packet; 
	 	
	.VAR 	PENDINGOUTSPIKE;	// is there a pending out spike packet? 
	.VAR 	PENDINGOUTCONT; 	// is there a pending out continuous packet

	// acqboard-related
	.VAR	CMDID;
	.VAR 	CMDIDPENDING; 
	
	// event status
	.VAR    EVENTIN[6];
	.VAR    EVENTDONE;
	.VAR 	EVENTOUT[5]; 
	  
		
.SECTION/DM seg_dm16da; 
#define OUTSPIKELEN 300

	.VAR	OUTSPIKE[OUTSPIKELEN]; // space to assemble the output spike; 
	.VAR 	NEWSAMPLES[5]; 	// new input samples
#define OUTCONTLEN 200
	.VAR 	OUTCONT[OUTCONTLEN]; // output space for continuous
		
	

.SECTION/PM seg_pmco; 

lock_mem:
	bit set imask IRQ0I;
	rts; 

unlock_mem:
	bit clr	imask IRQ0I; 
	rts; 
	


main: 
	nop;
	r0 = 0; 
main2:	
	nop;
	nop;
	r0 = r0 + 1; 

	
	call write_event; 
	
	
	
	
	
	jump main; 
	
	jump dispatch_event; 
	
	
init :  

	bit set mode1 CBUFEN; // enable circular buffers
	
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
	call	samples;
	call 	sd_newsamples; 
	 
	jump sample_loop; 
	
	
	
samples:
// Process inbound samples
// first, perform DMA, and add them to the end 
// 
// update NEWSAMPLES[5]

	r0 = dm(PENDINGOUTSPIKE);
	r0 = r0;  
	if GT jump samples_dmaspike; 
	r0 = dm(PENDINGOUTCONT);
	r0 = r0;  
	if GT jump samples_dmacont; 
	jump samples_convertnew; 
	

samples_dmaspike:
 	// dma out the spike
samples_dmacont:
	// dma out the continuous. We rely on the fact that
	// we'll only be sending a continuous frame every
	// CONTLEN * CONTDOWNSAMPLE (say, 64x4) samples, and at most
	// we're sending a spike packet every NOTRIGERLEN samples. 
	// this guarantees a maximum wait for the cont packet of 1
	// sample. 
	
	


// convert new samples to FP and save in circular buffers
	// we store the new sample at location n+1; 
samples_convertnew: 
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

	r0 = 1; 
	dm(PENDINGOUTSPIKE) = r0; 
	
	
samples_threshold_done:
		
check_continuous:
	r0 = dm(CONTCNT); 
	r1 = r0 - 1;
	dm(CONTCNT) = r1; 
	if GT jump continuous_done; 
	
	r0 = dm(CONTLEN); 	// update countdown
	dm(CONTCNT) = r0; 
	r1 = dm(CODOWNSAMPLE); // get downsample factor
	
	m8 = m11; 
	b8 = b11; 
	i8 = i11; 
	l8 = l11; 
	
	
	call create_continuous_packet; 
	r0 = 1; 
	dm(PENDINGOUTCONT) = r0; 
	

	
continuous_done:
 



 	
  	
  	
	

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
	
/*---------------------------------------------------------------
  create_continuous_packet : create packet of downsampled
  continuous data; 

  m8/i8/l8/b8 : pointer to continuous output circular buffer,
  				pointing to empty sample AFTER x[n]
  r0 = number of samples; 
  r1 = negative of downsample ratio; 
  
*/

create_continuous_packet:
	bit set mode1 CBUFEN; 
	i0 = OUTCONT; // set up base
	m0 = 1; 
	b0 = OUTCONT; 
	
// create length & ID word
	// each packet has 7 words of header
	r3 = 4; 
	r3 = r0 + r3; 	
	
	
	r2 = dm(MYID);	// MYID is in lower 8 bits
	r2 = r2 OR FDEP R3 BY 8:8;  // R3 in 8 MSBs!	
	
	dm(i0, m0) = r2 ; // store LENGTH && MYID
	

// timestamp
	r2 = dm(TIMESTAMP);
	r3 = FEXT r2 by 0:16; 
	dm(i0, m0) = r3;
	r3 = FEXT r2 by 16:16;
	dm(i0, m0) = r3;  

// sample and gain
	r3 = dm(COGAIN); // channel gain
	r2 = dm(COCHAN); // channel is lower 8 bits
	r2 = r2 OR FDEP r3 BY 8:8; 
	dm(i0, m0) = r2; 
	
	r2 = dm(COFID); 
	dm(i0, m0) = r2; 
	
	r2 = dm(COHFID); 
	dm(i0, m0) = r2; 
	
	// r1 is downsample factor
	r2 = r0; 	// number of samples
	r2 = r2 OR FDEP r1 BY 8:8; 
	dm(i0, m0) = r2; 
	
	// we set m8 so we can go back to the most recently written sample:
	m8 = -1;
	
	r2 = pm(i8, m8); 	// dummy read to position pointer back to most recent
						// sample.
	
	r1 = - r1; 			// the downsample factor == the decrement
	m8 = r1; 			// through the buffer.
	
	
	b1 = b0; 
	m1 = -1; 
	l1 = OUTCONTLEN;
	
	// i0 currently points to next empty spot to be filled
	// our index starts out pointing r0 words in the future, -1
	r1 = i0; 
	r1 = r1 - 1;  
	r1 = r1 + r0; // r1 = current outbuf point + num samples
	i1 = r1; 
		
	r4 = 15;  // conversion factor
	
	f3 = pm(i8, m8); // start the pipeline
	lcntr = r0, do cont_write_data until lce; 
		// we simultaneously get the next sample AND convert
		// the current sample
		r2 = FIX f3 by r4, f3 = pm(i8, m8);   
	cont_write_data: dm(i1, m1) = r2;
	// now, we need to update i1; 
	
	r2 = i0; 
	r2 = r2 + r0;
	i0 = r2; // update pointer to point to end of frame; 
	
	rts;
	
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
	
	r0 = EVENTIN; 	dm(IIPP) = r0; 	// starting point
	r0 = 1;			dm(IMPP) = r0; 

	r0 = 4;			dm(ICPP) = r0; 
	r0 = 1; 		dm(EMPP) = r0; 
	r0 = 0x4000;	dm(EIPP) = r0; 
	r0 = 8;			dm(ECPP) = r0; 

	
	
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
     writes an event
---------------------------------------------------*/

write_event:
	call	lock_mem; 
	
	// debugging;
	r0 = 0x4567CCDD; 	dm(EVENTOUT) = r0;
	r0 = 0xFDA189ab; 	dm(EVENTOUT + 1) = r0;
	r0 = 0x22221111; 	dm(EVENTOUT + 2) = r0;
	r0 = 0x44443333; 	dm(EVENTOUT + 3) = r0;
	r0 = 0x66665555;	dm(EVENTOUT + 4) = r0;
	
	
	ustat3 = PPDUR32 | PPTRAN | PPBHC | PP16 | PPEN | PPDEN;
	ustat4 = PPDUR32 | PPTRAN | PPBHC | PP16; 
	
	dm(PPCTL) = ustat4; 
	
	r0 = EVENTOUT; 	dm(IIPP) = r0; 	// starting point
	r0 = 1;			dm(IMPP) = r0; 

	r0 = 6;			dm(ICPP) = r0; 
	r0 = 1; 		dm(EMPP) = r0; 
	r0 = 0x4000;	dm(EIPP) = r0; 
	r0 = 12;		dm(ECPP) = r0; 

	
	
	dm(PPCTL) = ustat3; 
	
	nop;
	nop;
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
    

