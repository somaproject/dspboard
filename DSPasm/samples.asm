
#include <def21262.h>
#include "memory.h"

.SECTION/PM seg_pmco; 

samples:
// Process inbound samples
// first, perform DMA, and add them to the end 

	// disable our own interrupt
	bit set imask IRQ0I;
	bit set mode1 SRCU | SRRFH | SRRFL | SRD1H | SRD1L | SRD2H | SRD2L;  
	
	// switch to alternative register set
	

	call get_newsamples; 
	
	// check to see if we want to dma-out a sample. 
	
	r0 = dm(OUTSPIKE); 
	r1 = dm(PENDINGOUTSPIKE);
	r1 = r1;  
	if GT call send_data_packet_dma; 

	jump samples.process;
	r0 = dm(OUTCONT); 
	r1 = dm(PENDINGOUTCONT);
	r1 = r1;  
	if GT jump send_data_packet_dma; 
	
samples.process:

	call convert_newsamples; 
	
	call filter_channels;
	
	call threshold; 
	
	call check_continuous; 
	
	
	call wait_dma_done; // don't return until we've
		// finished out-putting all our DMA
	// i guess we could do some user code here
	
	// switch back from alternative register set
	bit clr mode1 SRCU | SRRFH | SRRFL | SRD1H | SRD1L | SRD2H | SRD2L;  
	
	
	// reenable sample interrupts
	bit clr	imask IRQ0I; 

	rti; 
	


	
/* -----------------------------------------------------
   send_data_packet_dma
		DMA-out data packet
		
		uses len from 8 msbs of first word
		
		input: 
	     r0 = pointer to buffer to tx in 16-bit memory
	    // note that we must shift the address into the
	    appropriate short-word address, and deal with the
	    word count accordingly.  
		
-------------------------------------------------------*/
send_data_packet_dma:
.global send_data_packet_dma; 
	r1 = 0x180000; 
	r2 = r0 - r1; 
	r2 = lshift r2 by -1; 
	r1 = 0xC0000; 
	r2 = r2 + r1; 
	
	i0 = r2; 
	
	r0 = dm(i0, 0); 
	r1 = fext r0 by 8:8; // r1 now has length in 16-bit words
	r3 = r1 + 1;		 // r3 = number of words / 2, rounded up
	r3 = lshift r3 by -1; 
	
	ustat3 = PPDUR16 | PPTRAN | PPBHC | PP16 | PPEN | PPDEN;
	ustat4 = PPDUR16 | PPTRAN | PPBHC | PP16; 
	 
       
	dm(PPCTL) = ustat4; 
	
	dm(IIPP) = r2; 	// starting point
	r0 = 1;			dm(IMPP) = r0; 

	dm(ICPP) = r3; 
	
	r0 = 1; 			dm(EMPP) = r0; 
	r0 = FPGA_OUTDATA;	dm(EIPP) = r0; 
	dm(ECPP) = r1; 
	
	
	dm(PPCTL) = ustat3; 

	rts; 
	

/* -----------------------------------------------------
   threshold:
   	generates a spike packet using
       the current locations of the SY[n] pointers and
       r0, the number of samples back to use. 
       
       uses current timestamp, i.e. TS is for the _end_
       of the packet. 
       
       creates with all 4 channels, using current gain
       etc. settings
       
       // inputs:
       r0 == the length of a spike, i.e. look back and
             capture r0 points
             
       // outputs:
       if in notrigger phase, returns
       if not in notrigger phase and get a spike
          that crosses threshold, 
          outspike has a spike
          PENDINGOUTSPIKE = 1; 
       if not in trigger phase and no spike, return.     
       
------------------------------------------------------*/	 

// check for thresholds
threshold:
    // this is a whee-bit ghetto because we need to manually
    // figure out what the address for POSTTRIGLEN is:

    r0 = dm(NOTRIGGER);
    r0 = r0 - 1; 
    dm(NOTRIGGER) = r0; 
    
    if GT rts; // we're still in a no-trigger phase
    
       
    r0 = dm(POSTTRIGLEN); 
  	
 	// channel 1 threshold check 
 	i8 = i11;	// sadly, circular buffering only works with
 	b8 = b11; 	// post-increment, thus we must do the dummy read
 	l8 = l11; 
 	m8 = r0; 			
 	f1 = pm(i8, m8); // dummy read to position pointer
 	f1 = pm(0, i8);	// get actual value
 	 
  	f2 = dm(STHRESH+0); 	// get the threshold
  	f2 = f1 - f2; 
  	if GE jump threshold.spikecross; 
 
 	// channel 2 threshold check 
 	i8 = i12;	// sadly, circular buffering only works with
 	b8 = b12; 	// post-increment, thus we must do the dummy read
 	l8 = l12; 
 	m8 = r0; 			
 	f1 = pm(i8, m8); // dummy read to position pointer
 	f1 = pm(0, i8);	// get actual value
 	 
  	f2 = dm(STHRESH+1); 	// get the threshold
  	f2 = f1 - f2; 
  	if GE jump threshold.spikecross; 

  	// channel 3 threshold check 
  	i8 = i13;	// sadly, circular buffering only works with
 	b8 = b13; 	// post-increment, thus we must do the dummy read
 	l8 = l13; 
 	m8 = r0; 			
 	f1 = pm(i8, m8); // dummy read to position pointer
 	f1 = pm(0, i8);	// get actual value
 	 
  	f2 = dm(STHRESH+2); 	// get the threshold
  	f2 = f1 - f2; 
  	if GE jump threshold.spikecross; 
  	
  	 	
 	// channel 4 threshold check 
 	i8 = i14;	// sadly, circular buffering only works with
 	b8 = b14; 	// post-increment, thus we must do the dummy read
 	l8 = l14; 
 	m8 = r0; 			
 	f1 = pm(i8, m8); // dummy read to position pointer
 	f1 = pm(0, i8);	// get actual value
 	 
  	f2 = dm(STHRESH+3); 	// get the threshold
  	f2 = f1 - f2; 
  	if GE jump threshold.spikecross;  
  	

  	rts; 
  		  	
threshold.spikecross:
	// we have a threshold crossing!
	
	
	r0 = dm(NOTRIGGERLEN);	// reset no-trigger window
	dm(NOTRIGGER) = r0; 
	
	r0 = dm(SPIKELEN);
	
	call create_spikepacket;  

	r0 = 1; 
	dm(PENDINGOUTSPIKE) = r0; 
	
	rts; 
	




/* -----------------------------------------------------
   check_continuous
   		checks to see if we've sampled enough of the
   		continuous samples, and if so creates an ouput
   		packet and sends them. 
   		
       
------------------------------------------------------*/		
check_continuous:
	r0 = dm(CONTCNT); 
	r1 = r0 - 1;
	dm(CONTCNT) = r1; 
	if GT rts; 
	
	r0 = dm(CONTLEN); 	// update countdown
	dm(CONTCNT) = r0; 
	r1 = dm(CODOWNSAMPLE); // get downsample factor
	
	m8 = m15; 
	b8 = b15; 
	i8 = i15; 
	l8 = l15; 
	
	
	call create_continuous_packet; 
	r0 = 1; 
	dm(PENDINGOUTCONT) = r0; 
	
	rts; 
	
	
	
	
/* -----------------------------------------------------
   create_spikepacket: generates a spike packet using
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

create_spikepacket:
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
	b8 = b11;
	i8 = i11; 
	l8 = l11;  // 
	r1 = 0;  	// channel number
	
	call create_spikepacket_channel_data; 

	// channel 2
	b8 = b12;
	i8 = i12; 
	l8 = l12;  // 
	r1 = 1;  	// channel number
	
	call create_spikepacket_channel_data; 

	// channel 3
	b8 = b13;
	i8 = i13; 
	l8 = l13; 
	r1 = 2;  	// channel number
	
	call create_spikepacket_channel_data; 

	// channel 4
	b8 = b14;
	i8 = i14;
	l8 = l14;  // 
	r1 = 3;  	// channel number
	
	call create_spikepacket_channel_data; 

	
	rts; 
	
	
	
/*----------------------------------------------------------------
  create_spikepacket_channel_data
  	Takes in a pointer to a non-interleaved output buffer via DAG2[0]
  	and the current location in DM where you wish to copy the relevant
  	channel location (nomally some place in OUTSPIKE) pointed to 
  	by DAG1[0], and formats the necesasry data. 
  	
  	Accesses various channel-dependent data structures, thus:
  	   r0 = number of samples of output buffer to transfer
  	   r1 = channel number; 
  	
------------------------------------------------------------------*/

create_spikepacket_channel_data:	
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
  
*---------------------------------------------------------------*/

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
	
/*----------------------------------------------------------
  get_newsamples:
        DMAs in new samples
         
     input:
        none
                  
     output:
        INSTATUS, NEWSAMPLES now has new samples, and status
         
     modifies:
	 	r0, r1, r2
	 	i5, i6, i7
-------------------------------------------------------------*/ 
get_newsamples:

	ustat3 = PPDUR10 | PPBHC | PP16 | PPEN | PPDEN;
	ustat4 = PPDUR10 | PPBHC | PP16; 
	
	dm(PPCTL) = ustat4; 
	
	r0 = INSTATUS; 		dm(IIPP) = r0; 	// starting point
	r0 = 1;				dm(IMPP) = r0; 

	r0 = 3;				dm(ICPP) = r0; 
	r0 = 1; 			dm(EMPP) = r0; 
	r0 = FPGA_SAMPLES;	dm(EIPP) = r0; 
	r0 = 6;				dm(ECPP) = r0; 

	dm(PPCTL) = ustat3; 
	
	nop;
	nop;
get_newsamples.wait:
	ustat4 = dm(PPCTL); 
	bit tst ustat4 PPDS;  // poll for dma status 
	if tf jump get_newsamples.wait; 
	    	

	rts; 
	
/*----------------------------------------------------------
  convert_newsamples:
        converts newsamples into floating point
        Saves them in appropriate memory buffers
        if the link is down, we just return zeros.  
     input:
        none
                  
     output:
        i5, i6, i7 now all point to location after
        the most recently written sample.
         
     modifies:
	 	r0, r1, r2
	 	i5, i6, i7
-------------------------------------------------------------*/ 
      	
convert_newsamples: 
	i0 = NEWSAMPLES; 
	m0 = 1; 
	r1 = -15; 
	
	r0 = dm(INSTATUS); 
	r0 = fext r0 by 0:1; 
	if gt jump convert_newsamples.error; 
	
	r0 = dm(0x0, i0); 		// sample for channel 1;
	f2 = FLOAT r0 by r1;	// multiply by 2^-15 
	dm(i5, m0) = f2; 

	r0 = dm(0x1, i0); 		// sample for channel 2;
	f2 = FLOAT r0 by r1;	// multiply by 2^-15  
	dm(i5, m0) = f2; 
	 
	
	r0 = dm(0x2, i0); 		// sample for channel 3;
	f2 = FLOAT r0 by r1;	// multiply by 2^-15  
	dm(i6, m0) = f2; 

	r0 = dm(0x3, i0); 		// sample for channel 4;
	f2 = FLOAT r0 by r1;	// multiply by 2^-15  
	dm(i6, m0) = f2; 
	 
	r0 = dm(0x4, i0); 		// sample for channel C;
	f2 = FLOAT r0 by r1;	// multiply by 2^-15  
	dm(i7, m0) = f2; 
	
	rts; 

convert_newsamples.error:
	
	rts; 	
/*----------------------------------------------------------
  filter_channels:
        FIR filters all data channels
         
     input:
        expects standard global pointers to buffers
                  
     output:
        outputs go to output pm buffers
        
     modifies:
		everything; don't call from within something :)
				     
-------------------------------------------------------------*/ 

	
filter_channels:

// perform filtering
	
	// configure for channels 1 & 2
	 
	r0 = dm(SHLEN); 	// get SHLEN[0]
	r1 = dm(SHLEN+1); 	// get SHELN[1]
	
	r0 = max(r0, r1); // length of filter is max of the two 
	
		
	b0 = b5; 		// base of spike chans 1 & 2
	m0 = -2;  		// go backward by 2
	l0 = l5;  		// same length
	i0 = i5;		// currently points to one sample past most
					// recent
	r1 = dm(i0, m0);// so move pointer back one
	
	
	
	// configure for filter for channesl 1 & 2
	b8 = SH12;
	m8 = 2; // incrememnt by 2, i.e. interleaved
	i8 = SH12;
	l8 = dm(SHSIZE);
	
	call filter_fir_simd; 
	
	pm(i11, m11) = f0;	// save result from spike 1
	pm(i12, m12) = f1;  // save result from spike 2
	
	
	// configure for channels 3 & 4
	i0 = SHLEN; 
	r0 = dm(0x2, i0); // get SHLEN[2]
	r1 = dm(0x3, i0); // get SHELN[3]
	
	r0 = max(r0, r1); 	
		
	b0 = b6; 		// base of spike chans 3& 4
	m0 = -2;  		// go backward by 2
	l0 = l6;  		// same length
	i0 = i6;		// currently points to one sample past most
					// recent
	r1 = dm(i0, m0);// so move pointer back one
	
	// configure for filter for channesl 3 & 4
	b8 = SH34;
	m8 = 2; // incrememnt by 2. i.e. interleaved
	i8 = SH34;
	l8 = dm(SHSIZE);
	

	call filter_fir_simd; 
	
	pm(i13, m13) = f0;	// save result from spike 3
	pm(i14, m14) = f1;  // save result from spike 4
	
	
	// configure for continuous channel
	
	b0 = b7; // base of continuous channel
	m0 = -1;  // go backward by 1
	i0 = i7;  // we're at the base
	l0 = l7;  // same length
	r0 = dm(i0, m0); 
	
	// configure for filter for continuous channel
	b8 = COH;
	m8 = 1; // incrememnt by 1
	i8 = COH;
	l8 = COHSIZE;
	
	r0 = dm(COHLEN); // length of filter
	call filter_fir; 
	
	pm(i15, m15) = f0;	// save result from continuous

	rts; 
	

/* ------------------------------------------------------
   filter_fir : 
	   performs an N (N = r0) tap floating point
	   convolution of the buffer pointed to by DAG1[0] and 
	   the filter DAG2[0]; 
	   
	   DAGs are set up ahead of time; this function is ignorant
	   as to increment size or circularity
	   
	   note that DAGs must be pointing to the sample
	   at x[n], i.e. the most recent sample (NOT THE SLOT
	   AFTER THAT) 
	   
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
			
	rts (DB); 
	f8=f8+f12; 
	
	f0 = f8; // return result; 
		


/*------------------------------------------------------
  filter_fir_simd performs 
  	SIMD filtering, with DAGs pointing
  	to relevant filters. R0 is length of conv. 
  
  	simple, really: just enables secondary computation unit, make
 	sure modifiers are set to 2, then calls normal filter_FIR routine
  
	  inputs: 
	      i0: points to the circular buffer for x[n] coeff
	      i8: points to the coefficient buffer
	      
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
	
	rts (DB);
	bit clr mode1 PEYEN; // disable secondary computation unit.  
	nop; 
	
	
/*------------------------------------------------------
  wait_dma_done: 
  	SIMD filtering, with DAGs pointing
  	to relevant filters. R0 is length of conv. 
  
  	simple, really: just enables secondary computation unit, make
 	sure modifiers are set to 2, then calls normal filter_FIR routine
  
	  inputs: 
	      none; 
	      
	  outputs: 
	      none; returns when DMA is done. 
	      
	  modifies:
	      ustat4; 
 -------------------------------------------------------*/
 wait_dma_done:
	ustat4 = dm(PPCTL); 
	bit tst ustat4 PPDS;  // poll for dma status 
	if tf jump wait_dma_done; 
	

/*----------------------------------------------------------
  zerodata:
        zeros all input, output buffers
        note that this does not impact the existing DAGs, 
        i.e. they are NOT RESET
        
     input:
        none
                  
     output:
        all appropriate buffers are now filled with zeros:
        SX12
        SX34
        COX
        SY12
        SY34
        COY         
         
     modifies:
	 	r0, i0-i3; 
-------------------------------------------------------------*/ 
samples.zerodata:	// global function to call from events
.global samples.zerodata;
zerodata:

	// spike data chans 12, 34
	
	b0 = SX12;
	m0 = 1; 
	i0 = SX12;
	l0 = SXSIZE; 
	b1 = SX34; 
	i1 = SX34;
	l1 = SXSIZE; 
	
	f0 = 0.0; 
	lcntr = SXSIZE; do zerodata.sx until lce; 
		dm(i0, m0) = f0; 
	zerodata.sx:	dm(i1, m0) = f0; 
	
	
	// continuous input channel
	
	b0 = COX;
	m0 = 1; 
	i0 = COX;
	l0 = COXSIZE; 
	
	f0 = 0.0; 
	lcntr = COXSIZE; do zerodata.cox until lce; 
		dm(i0, m0) = f0; 
	zerodata.cox:	nop;
		nop; 	

	// spike output channels 1-4
	
	b8 = SY1;
	m8 = 1; 
	i8 = SY1;
	l8 = SYSIZE; 
	b9 = SY2; 
	i9 = SY2;
	l9 = SYSIZE; 
	b10 = SY2; 
	i10 = SY2;
	l10 = SYSIZE; 
	b11 = SY2; 
	i11 = SY2;
	l11 = SYSIZE; 
	
	f0 = 0.0; 
	lcntr = SYSIZE; do zerodata.sy until lce; 
		pm(i8, m8) = f0; 
		pm(i9, m8) = f0; 
		pm(i10, m8) = f0;		
	zerodata.sy:		pm(i11, m8) = f0;  
	
	
	// DAG2[3]: output pointer for continuous
	b8 = COY;
	m8 = 1; 
	i8 = COY;
	l8 = COYSIZE; 
	
	f0 = 0.0; 
	lcntr = COYSIZE; do zerodata.coy until lce; 
	zerodata.coy:		pm(i8, m8) = f0;  
	
	rts;
	  		
