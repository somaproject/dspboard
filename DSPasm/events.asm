sta

#include <def21262.h>
#include "memory.h"

.SECTION/PM seg_pmco;



/*------------------------------------------------------
  events: 
  	This is the main event loop; we get here after
  	the init sequence has completed.  
  	
 -------------------------------------------------------*/
events:
	call read_status; 
	call check_link;
	call check_acqcmd; 
	call read_event; 
	call dispatch_event; 
	
	
 

/*------------------------------------------------------
  read_status: 
  	DMA in the new status word and save in NEWSTAT
  	  	
	inputs: 
		none; 
	      
	outputs: 
		NEWSTAT contains most recent status word

	modifies:
		all the PP DMA registers
		    
 -------------------------------------------------------*/
 read_status:
 

/*------------------------------------------------------
  check_link: 
  	checks to see if the link status has changed by comparing
  	STATUS bit of NEWSTAT with LINKSTAT
  	
  	if changed, updates LINKSTAT, sends event
  	if we went from up to down, calls update_sampling to 
  	   change sampling mode to 0
  	  	
	inputs: 
		LINKSTAT
	      
	outputs: 
		NEWSTAT contains most recent status word

	modifies:
		r0, r1; 
		    
 -------------------------------------------------------*/
check_link:
	r0 = dm(LINKSTAT); 
	r1 = dm(NEWSTAT); 
	r1 = fext r1 by 0:1; // get the status bit out
	comp (r0, r1); 
	if eq rts;    /// no change, return
	
	// here, we're at a new link state
	r0 = 0; 
	dm(CMDIDPENDING) = r0; 
	dm(LINKSTAT) = r1;  	// update linkstat
	
	// send linkchange event
	r3 = r1; 		// r3 == dw0 == link status
	r0 = 0xFFFFFFFF; // broadcast
	r1 = 0xFFFFFFFF; 
	r2 = 0x10; // link status event
	call write_event; 
	
	r0 = dm(LINKSTAT); 
	r1 = 0; 
	comp(r0, r1); 
	if eq call update_sampling; 
	
	rts; 
	
	
	
	

/*------------------------------------------------------
  update_sampling: 
  	sets SAMPLING (i.e. sampling state) to value in r0
  	disable SAMPLE interrupt
  	send an event about the change in status
  	zero relevant buffers
  	  	
	inputs: 
		r0 = sampling state
	      
	outputs: 
		SAMPLING=1, we also zero the relevant data input
		buffers
		
		sends broadcast event about sampling state

	modifies:
		r0, r1, r2, r3 
		    
 -------------------------------------------------------*/
update_sampling:
	r1 = 1; 
	comp (r1, r0); 
	if eq jump update_sampling.on; 
	
	

	update_sampling.on: 	// sampling is on
		// set sampling
	
		r0 = 0xFFFFFFFF; 	// write event
		r1 = 0xFFFFFFFF; 
		r2 = 0x11; 				// data record event
		r3 = dm(SAMPLING); 
		call write_event; 
		
		.extern samples.zerodata; 
		call samples.zerodata;
		
		r0 = 1;
		dm(SAMPLING) = r0; 

		bit clr imask IRQ0I; 	// enable interrupts
	
	
	update_sampling.off:	// no longer sampling
		bit set imask IRQ0I; 	// disable SAMPLING int
		r0 = 0; 
		dm(SAMPLING) = r0; 
			
		r0 = 0xFFFFFFFF; 	// write event
		r1 = 0xFFFFFFFF; 
		r2 = 0x11; 				// data record event
		r3 = dm(SAMPLING); 
		call write_event; 	

	update_sampling.done:	// done sampling; 
		rts; 
 
  

/*------------------------------------------------------
  dispatch_event: 
  	looks at read-in event and dispatches it to the
  	appropriate sub
  	
  	inputs: 
		r11 = command byte 
		r12 = sender
		r13 = data word 0 
		r14 = data word 2 | data word 1
		r15 = data word 4 | data word 3;	      

	outpus: none
	
	modifies:
	    ustat3, ustat4, r0 
	    uses EVENTIN as a temporary buffer
	    
 -------------------------------------------------------*/
dispatch_event: 

	
	r0 = 0x40; 
	COMP(r0, r11);
	if EQ jump set_sampling;
		
	r0 = 0x41; 
	COMP(r0, r11);
	if EQ jump param_read;
	
	r0 = 0x42; 
	COMP(r0, r11);
	if EQ jump param_write;

	r0 = 0x43; 
	COMP(r0, r11);
	if EQ jump acq_set;

	r0 = 0x44; 
	COMP(r0, r11);
	//if EQ jump acq_query;
	
	   
 
dispatch_event_end:
// done with event


/*------------------------------------------------------
  read_event: 
  	Reads an event over DMA from the FPGA and returns it
  	in the high registers. 
  	
  	calls lock_mem to prevent DMA/PP contention
  	
  	
	inputs: 
		none; 
	      
	outputs: 
		r11 = command byte 
		r12 = sender
		r13 = data word 0 
		r14 = data word 2 | data word 1
		r15 = data word 4 | data word 3;	      

	modifies:
	    ustat3, ustat4, r0 
	    uses EVENTIN as a temporary buffer
	    
 -------------------------------------------------------*/
 
read_event:
	call	lock_ppdma; 
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
	
read_event.wait:
	ustat4 = dm(PPCTL); 
	bit tst ustat4 PPDS;  // poll for dma status 
	if tf jump read_event.wait; 
	
	r0 = dm(EVENTIN); 
	r11 = FEXT r0 BY 0:8;
	r12 = FEXT r0 BY 8:8;
	r13 = FEXT r0 BY 16:16;
	r14 = dm(EVENTIN+1);
	r15 = dm(EVENTIN+2); 
	call	unlock_ppdma; 
	
	rts; 

/*------------------------------------------------------
  write_event: 
  	Writes an event over DMA to the FPGA 
  	
  	calls lock_mem to prevent DMA/PP contention
  	
  	
	inputs: 
		r0 =  address bits 31:0
		r1 =  address bits 47:32 (in LSBs)
		r2 =  command (8 lower bits)
		r3 =  data word 1
		r4 =  dw 3 | 2
		r5 = dw 5 | 4; 
		      
	outputs: 
		none
		
	modifies:
	    ustat3, ustat4, r0 
	    uses EVENTOUT as a temporary buffer
	    
 -------------------------------------------------------*/
 
write_event:
	call	lock_ppdma; 
	
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

	dm(PPCTL) = ustat3; 
write_event.wait:
	ustat4 = dm(PPCTL); 
	bit tst ustat4 PPDS;  // poll for dma status 
	if tf jump write_event.wait; 
	
	
	call	unlock_ppdma; 
	
	rts; 


/*------------------------------------------------------
  param_write: 
  	Writes an internal parameter. 
  	
  	takes in standard event registers
     extracts TARGET, that is, what we're writing
     and ADDR, which is in most cases the address
     of a buffer, etc. 	  	
  	
	inputs: 
		r11-r15: standard read_event configuration
		      
	outputs: 
		none
		
	modifies:
	    ustat3, ustat4, r0 
	    uses EVENTOUT as a temporary buffer
	    
 -------------------------------------------------------*/	

param_write:
    r0 = FEXT r13 BY 8:8; // RO is target
    r1 = FEXT r13 by 0:8; // R1 is address
    
	// case statement:
	
	param_write.case_spike_fir_1:
		r2 = 0x10;
		COMP(r2, r0);
		IF NE JUMP param_write.case_spike_fir_2; 
		call param_write.spike_fir_1;
		jump param_write_endcase; 
			
	param_write.case_spike_fir_2:
		r2 = 0x11;
		COMP(r2, r0);
		IF NE JUMP param_write.case_spike_fir_3; 
		call param_write.spike_fir_2;
		jump param_write_endcase; 
	
	param_write.case_spike_fir_3:
		r2 = 0x12;
		COMP(r2, r0);
		IF NE JUMP param_write.case_spike_fir_4; 
		call param_write.spike_fir_3;
		jump param_write_endcase; 
	
	
	param_write.case_spike_fir_4:
		r2 = 0x13;
		COMP(r2, r0);
		IF NE JUMP param_write.case_cont_fir; 
		call param_write.spike_fir_4;
		jump param_write_endcase; 
	
	param_write.case_cont_fir:
		r2 = 0x14;
		COMP(r2, r0);
		IF NE JUMP param_write.case_filterlen; 
		call param_write.cont_fir;
		jump param_write_endcase; 
	
	param_write.case_filterlen:
		r2 = 0x20;
		COMP(r2, r0);
		IF NE JUMP param_write.case_filterID; 
		call param_write.filterlen;
		jump param_write_endcase; 
	
	param_write.case_filterID:
		r2 = 0x21;
		COMP(r2, r0);
		IF NE JUMP param_write.case_spikelen; 
		call param_write.filterID;
		jump param_write_endcase; 

	param_write.case_spikelen:
		r2 = 0x23;
		COMP(r2, r0);
		IF NE JUMP param_write.case_notriggerlen; 
		call param_write.spikelen;
		jump param_write_endcase; 
			
	param_write.case_notriggerlen:
		r2 = 0x24;
		COMP(r2, r0);
		IF NE JUMP param_write.case_posttriglen; 
		call param_write.notriggerlen;
		jump param_write_endcase; 
	
	param_write.case_posttriglen:
		r2 = 0x25;
		COMP(r2, r0);
		IF NE JUMP param_write.case_filterlen; 
		call param_write.posttriglen; 
		jump param_write_endcase; 

					
	param_write.case_downsample:
		r2 = 0x26;
		COMP(r2, r0);
		IF NE JUMP param_write.case_contlen; 
		call param_write.downsample;
		jump param_write_endcase; 
	
	param_write.case_contlen:
		r2 = 0x27;
		COMP(r2, r0);
		IF NE JUMP param_write_endcase; 
		call param_write.contlen; 
		jump param_write_endcase; 
	
		
	param_write_endcase:
		
	param_write.end:
		// done!
			
	 
		
		
		
	param_write.spike_fir_1:
		r5 = dm(SHLEN);
		r4 = 2; 
		r4 = r5 - r4;  // make sure we're not trying to write too far
		COMP(r4, r1); 
		if LT jump param_write.error;  
		
		i8 = SH12;
		r3 = LSHIFT R1 by 1; 			// multiply by two 
		r3 = r3 + 1, m8 = r3; 			// inc r3 to point to h2[n]
		r3 = r3 + 1, pm(m8, i8) = r14;  // inc r3 to point to h1[n+1]
										// store DW0 in h1[n];  
		m8 = r3; 
		pm(m8, i8) = r15; 				// store DW1 in h1[n+1]; 
		
		rts; 
	
	param_write.spike_fir_2:
		r5 = dm(SHLEN);
		r4 = 2; 
		r4 = r5 - r4;  // make sure we're not trying to write too far
		COMP(r4, r1); 
		if LT jump param_write.error;  
		
		i8 = SH12;
		r3 = LSHIFT R1 by 1; 			// multiply by two 
		r3 = r3 + 1; 					// the H2s are one-off
		r3 = r3 + 1, m8 = r3; 			// inc r3 to point to h1[n+1]
		r3 = r3 + 1, pm(m8, i8) = r14;  // inc r3 to point to h2[n]
										// store DW0 in h2[n]; 
		m8 = r3; 
		pm(m8, i8) = r15; 				// store DW1 in h2[n+1]; 
		
		rts;
		
	param_write.spike_fir_3:
		r5 = dm(SHLEN);
		r4 = 2; 
		r4 = r5 - r4;  // make sure we're not trying to write too far
		COMP(r4, r1); 
		if LT jump param_write.error;  
		
		i8 = SH34;
		r3 = LSHIFT R1 by 1; 			// multiply by two 
		r3 = r3 + 1, m8 = r3; 			// inc r3 to point to h4[n]
		r3 = r3 + 1, pm(m8, i8) = r14;  // inc r3 to point to h3[n+1]
										// store DW0 in h3[n]; 
		m8 = r3; 
		pm(m8, i8) = r15; 				// store DW1 in h3[n+1]; 
		
		rts;
	
	param_write.spike_fir_4:
		r5 = dm(SHLEN);
		r4 = 2; 
		r4 = r5 - r4;  // make sure we're not trying to write too far
		COMP(r4, r1); 
		if LT jump param_write.error;  
		
		i8 = SH34;
		r3 = LSHIFT R1 by 1; 			// multiply by two 
		r3 = r3 + 1; 					// the H4s are one-off
		r3 = r3 + 1, m8 = r3; 			// inc r3 to point to h3[n+1]
		r3 = r3 + 1, pm(m8, i8) = r14;  // inc r3 to point to h4[n]
										// store DW0 in h4[n]; 
		m8 = r3; 
		pm(m8, i8) = r15; 				// store DW1 in h4[n+1]; 
		
		rts;
		
	param_write.cont_fir:
		r5 = dm(COHLEN);
		r4 = 2; 
		r4 = r5 - r4;  // make sure we're not trying to write too far
		COMP(r4, r1); 
		if LT jump param_write.error;  
		
		i8 = COH;
		m8 = r3; 						// m8 = address
		r3 = r3 + 1, pm(m8, i8) = r14;  // inc r3 to point to hc[n+1]
										// store DW0 in h1[n];
		m8 = r3; 								 
		pm(m8, i8) = r15; 				// store DW1 in h1[n+1]; 
		
		rts;
		
	param_write.filterlen:
		r4 = 4; 
		COMP(r4, r1);
		if LT jump param_write.error; 
		
		if EQ jump param_write.filterlen_cont;
		
		// spike channel lengths
		i0 = SHLEN; 
		m0 = r1; 
		r4 = FEXT r14 BY 0:8 ; // only get the lower 8 bits of the filter length; 
		dm(m0, i0) = r4; 
		rts;
	
	param_write.filterlen_cont:
		r4 = FEXT r14 BY 0:8;
		dm(COHLEN) = r4; 
		rts;
		
	param_write.filterID:
		r4 = 4; 
		COMP(r4, r1);
		if LT jump param_write.error; 
		
		if EQ jump param_write.filterID_cont;
		
		// spike channel lengths
		i0 = SFID; 
		m0 = r1; 
		r4 = FEXT r14 BY 0:16 ; // only get the lower 16 bits of the filter ID 
		dm(m0, i0) = r4; 
		jump param_write.end;
	
	param_write.filterID_cont:
		r4 = FEXT r14 BY 0:16;
		dm(COFID) = r4; 
		jump param_write.end;
		
	param_write.spikelen:
		r4 = FEXT r14 by 0:8; 
		dm(SPIKELEN) = r4; 
		jump param_write.end; 
		
	param_write.notriggerlen:
		r4 = FEXT r14 by 0:8; 
		dm(NOTRIGGERLEN) = r4; 
		jump param_write.end; 
		
	param_write.posttriglen:
		r4 = FEXT r14 by 0:8; 
		dm(POSTTRIGLEN) = r4; 
		jump param_write.end; 
		
	param_write.downsample:
		r4 = FEXT r14 by 0:4; 
		dm(CODOWNSAMPLE) = r4; 
		jump param_write.end; 
		
	param_write.contlen:
		r4 = FEXT r14 by 0:8; 
		dm(CONTLEN) = r4; 
		jump param_write.end; 
	
		
			
	param_write.error:
		// some sort of error-related thing here; 
	
	
	
    
    
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
    
	

/*------------------------------------------------------
  check_acqcmd: 
  	check to see if cmdid has been updated, and if so, says whee!
  	
  	
	inputs: 
		none; 
		      
	outputs: 
		none
		
	modifies:
	    ustat3, ustat4, r0 
	    uses EVENTOUT as a temporary buffer
	    
 -------------------------------------------------------*/
check_acqcmd:
     r1 = dm(CMDIDPENDING);
     r2 = -1;
     comp(r1, r2); 
     if eq rts; // command pending is =1, therefor we're not waiting
     			// and thus don't care
     
     r0 = dm(NEWSTAT); 
     r2 = fext r0 by 4:3; // extract cmdid
     comp(r1, r2); 
     
     if ne rts;   // still waiting for result 
     			  // cmdidpending != newstat.cmdid
     
     // else, we were waiting for a CMDID and it
     // has arrived:
     r0 = -1; 
     dm(CMDIDPENDING) = r0; 	// reset CMDIDPENDING
     call update_from_cmdpending;
     call broadcast_acqstate; 
     

     
         
/*------------------------------------------------------
  update_from_cmdpending; 
  	updates system state based on the pending comman
  	// this is interesting; we assume we never send
  	// a command that would set something that the
  	// other DSP is supposed to be worrying about, and
  	// that's that. 
  	
  	// note that CMDPENDING will be structured such that
  	CMDPENDING[1]:
  		lowest byte: command DATA0
  		highest byte: command DATA3;  		
  	 	
	inputs: 
		DMDPENDING;  
		      
	outputs: 
		none
		
	modifies:
		r1 - r7 (ouch!)
		
	    
 -------------------------------------------------------*/  
 update_from_cmdpending:
 	r0 = dm(CMDPENDING); 
 	r0 = fext r0 by 0:4; // get actual command
 	
 	r1 = 0x1; 
 	comp(r0, r1); // gain check
 	if eq jump update_from_cmdpending.setgain; 
 	
  	r1 = 0x2; 
 	comp(r0, r1); // gain check
 	if eq jump update_from_cmdpending.input; 
 	
  	r1 = 0x3; 
 	comp(r0, r1); // gain check
 	if eq jump update_from_cmdpending.hpfilter;
 	
 	rts; // haven't implemented others yet
 	
	update_from_cmdpending.setgain:
	r0 = dm(CMDPENDING+1); 
	r1 = fext r0 by 0:4; // get DATA0; 
	// chan 0-3 : tetrode A spike chan
	// chan 4 : tetrode A cont chan
	// chan 5 : tetrode B cont chan
	// chan 6-9 : tetrode B set chan. 
	r3 = 5; 
	r5 = 4;
	r7 = 6; 
	r6 = r1 - r7; 
	r2 = r1 - r3; // if result is negative, original was
				  // for tetrode A
	
	if lt r4 = r1; 	
	if eq r4 = r5; 
	if gt r4 = r6; 
	
	r2 = fext r0 by 8:3;  	// get fggain value
	r1 = 4; 
	m0 = r4; 
	i0 = SGAIN; 
	i1 = COGAIN; 
	comp(r4, r1); 
	if eq dm(0, i1) = r2;
	if ne dm(m0, i0) = r2; 
	
	
	rts; 
	
	
	update_from_cmdpending.input:
	r0 = dm(CMDPENDING+1); // again, we assume that this was really for us
	r1 = fext r0 by 8:2;    
	dm(COCHAN) = r1; 
	
	rts;
	
	update_from_cmdpending.hpfilter:
	r0 = dm(CMDPENDING+1); 
	r1 = fext r0 by 0:4; // get DATA0; 
	// chan 0-3 : tetrode A spike chan
	// chan 4 : tetrode A cont chan
	// chan 5 : tetrode B cont chan
	// chan 6-9 : tetrode B set chan. 
	r3 = 5; 
	r5 = 4;
	r7 = 6; 
	r6 = r1 - r7; 
	r2 = r1 - r3; // if result is negative, original was
				  // for tetrode A
	
	if lt r4 = r1; 	
	if eq r4 = r5; 
	if gt r4 = r6; 
	
	r2 = fext r0 by 8:3;  	// get fggain value
	r1 = 4; 
	m0 = r4; 
	i0 = SHFID; 
	i1 = COHFID; 
	comp(r4, r1); 
	if eq dm(0, i1) = r2;
	if ne dm(m0, i0) = r2; 
	
	
	rts; 
	
/*------------------------------------------------------
  broadcast_acqstate; 
  	sends out event updating system of current tetrode
  	hardware state
  	
  	inputs: 
		all relevant hardware variables
		      
	outputs: 
		none
		
	modifies:
		
		
	    
 -------------------------------------------------------*/  
broadcast_acqstate:
	r4 = 0; 
	r0 = dm(SGAIN); 
	r4 = r4 or fdep r0 by 0:4;
	r0 = dm(SHFID); 
	r4 = r4 or fdep r0 by 4:2; 
	r0 = dm(SGAIN+1); 
	r4 = r4 or fdep r0 by 8:4;
	r0 = dm(SHFID+1); 
	r4 = r4 or fdep r0 by 12:2;
	r0 = dm(SGAIN+2); 
	r4 = r4 or fdep r0 by 16:4;
	r0 = dm(SHFID+2); 
	r4 = r4 or fdep r0 by 20:2; 
	r0 = dm(SGAIN+3); 
	r4 = r4 or fdep r0 by 24:4;
	r0 = dm(SHFID+3); 
	r4 = r4 or fdep r0 by 28:2;
	 
	r5 = 0; 
	r0 = dm(COGAIN); 
	r4 = r4 or fdep r0 by 0:4;
	r0 = dm(COHFID); 
	r4 = r4 or fdep r0 by 4:2;
	r0 = dm(COCHAN); 
	r4 = r4 or fdep r0 by 6:2;
	

	r0 = 0xFFFFFFFF; 
	r1 = r0; 
	r2 = 12; 
	r3 = 0x00; // this is the acqstate update
	
	call write_event; 
	
	rts; 
	

	

/*------------------------------------------------------
  set_sampling: 
  	simple wrapper to set SAMPLING via udpate_sampling
  	  	
	inputs: 
		standard event register set
	      
	outputs: 
		calls update_sampling with relevant bits

	modifies:
		
		    
 -------------------------------------------------------*/	
 set_sampling:
 	r0 = fext r13 by 0:1; 
 	call update_sampling;
 	
 	rts; 
 	
/*------------------------------------------------------
  param_read: 
  	Reads and returns an internal parameter; 
  	
  	takes in standard event registers
     extracts TARGET, that is, what we're writing
     and ADDR, which is in most cases the address
     of a buffer, etc. 	  	
  	
	inputs: 
		r11-r15: standard read_event configuration
		      
	outputs: 
		none
		
	modifies:
	    ustat3, ustat4, r0 
	    uses EVENTOUT as a temporary buffer
	    
 -------------------------------------------------------*/	
param_read:
    r0 = FEXT r13 BY 8:8; // RO is target
    r1 = FEXT r13 by 0:8; // R1 is address


	param_read.case_spike_fir_1:
		r2 = 0x10;
		COMP(r2, r0);
		IF NE JUMP param_read.case_spike_fir_2; 
		
		r5 = dm(SHLEN);
		r4 = 2; 
		r4 = r5 - r4;  // make sure we're not trying to write too far
		COMP(r4, r1); 
		if LT jump param_read.error;  
		
		i8 = SH12;
		r3 = LSHIFT R1 by 1; 			// multiply by two 
		r3 = r3 + 1, m8 = r3; 			// inc r3 to point to h2[n]
		r3 = r3 + 1, r4 = pm(m8, i8) ;  // inc r3 to point to h1[n+1]
										// store h1[n] in r4 for DW0  
		m8 = r3; 						// 
		r5 = pm(m8, i8); 				// store h1[n+1] in r5 for DW1    		
			
		jump param_read.sendevent; 
			
	param_read.case_spike_fir_2:
		r2 = 0x11;
		COMP(r2, r0);
		IF NE JUMP param_read.case_spike_fir_3; 
		
		r5 = dm(SHLEN);
		r4 = 2; 
		r4 = r5 - r4;  // make sure we're not trying to write too far
		COMP(r4, r1); 
		if LT jump param_read.error;  
		
		i8 = SH12;
		r3 = LSHIFT R1 by 1; 			// multiply by two 
		r3 = r3 + 1; 					// the H2s are one-off
		r3 = r3 + 1, m8 = r3; 			// inc r3 to point to h1[n+1]
		r3 = r3 + 1, r4 = pm(m8, i8);   // inc r3 to point to h2[n]
										// store h2[n] in r4 (DW0) 
		m8 = r3; 
		r5 = pm(m8, i8); 				// store h2[n+1] in r5 (DW1);  
		
		jump param_read.sendevent; 
	
	param_read.case_spike_fir_3:
		r2 = 0x12;
		COMP(r2, r0);
		IF NE JUMP param_read.case_spike_fir_4; 
		
		r5 = dm(SHLEN);
		r4 = 2; 
		r4 = r5 - r4;  // make sure we're not trying to write too far
		COMP(r4, r1); 
		if LT jump param_read.error;  
		
		i8 = SH34;
		r3 = LSHIFT R1 by 1; 			// multiply by two 
		r3 = r3 + 1, m8 = r3; 			// inc r3 to point to h2[n]
		r3 = r3 + 1, r4 = pm(m8, i8) ;  // inc r3 to point to h1[n+1]
										// store h1[n] in r4 for DW0  
		m8 = r3; 						// 
		r5 = pm(m8, i8); 				// store h1[n+1] in r5 for DW1    		
			
		jump param_read.sendevent; 
	
	
	param_read.case_spike_fir_4:
		r2 = 0x13;
		COMP(r2, r0);
		IF NE JUMP param_read.case_cont_fir; 
		
		r5 = dm(SHLEN);
		r4 = 2; 
		r4 = r5 - r4;  // make sure we're not trying to write too far
		COMP(r4, r1); 
		if LT jump param_read.error;  
		
		i8 = SH34;
		r3 = LSHIFT R1 by 1; 			// multiply by two 
		r3 = r3 + 1; 					// the H2s are one-off
		r3 = r3 + 1, m8 = r3; 			// inc r3 to point to h1[n+1]
		r3 = r3 + 1, r4 = pm(m8, i8);   // inc r3 to point to h2[n]
										// store h2[n] in r4 (DW0) 
		m8 = r3; 
		r5 = pm(m8, i8); 				// store h2[n+1] in r5 (DW1);  
		
		jump param_read.sendevent; 
	
	param_read.case_cont_fir:
		r2 = 0x14;
		COMP(r2, r0);
		IF NE JUMP param_read.case_filterlen; 
		r5 = dm(COHLEN);
		r4 = 2; 
		r4 = r5 - r4;  // make sure we're not trying to write too far
		COMP(r4, r1); 
		if LT jump param_read.error;  
		
		i8 = COH;
		m8 = r3; 						// m8 = address
		r3 = r3 + 1, r4 = pm(m8, i8);  // inc r3 to point to hc[n+1]
										// h1[n] in r4 (DW0); 
		m8 = r3; 								 
		r5 = pm(m8, i8); 				// h1[n+1] in r5 (DW1);  

		jump param_read.sendevent; 
		
			
	param_read.case_filterlen:
		r2 = 0x20;
		COMP(r2, r0);
		IF NE JUMP param_read.case_filterID; 
		
		r4 = 4; 
		COMP(r4, r1);
		if LT jump param_read.error; 
		
		if EQ jump param_read.case_filterlen_cont;
		
		// spike channel lengths
		i0 = SHLEN; 
		m0 = r1;  
		r4 = dm(m0, i0); 

		jump param_read.sendevent; 

	param_read.case_filterlen_cont:
		i0 = COHLEN; 
		r4 = dm(0, i0); 

		jump param_read.sendevent; 	
			
	param_read.case_filterID:
		r2 = 0x21;
		COMP(r2, r0);
		IF NE JUMP param_read.case_spikelen; 

		r4 = 4; 
		COMP(r4, r1);
		if LT jump param_read.error; 
		
		if EQ jump param_read.case_filterID_cont;
		
		// spike channel lengths
		i0 = SFID; 
		m0 = r1; 
		r4 = dm(m0, i0); 
		jump param_read.sendevent;
	
	param_read.case_filterID_cont:
		r4 = dm(COFID); 
		jump param_read.sendevent; 
		
	
	param_read.case_spikelen:
		r2 = 0x23;
		COMP(r2, r0);
		IF NE JUMP param_read.case_notriggerlen;
		r4 = dm(SPIKELEN);		
		jump param_read.sendevent; 
			
	param_read.case_notriggerlen:
		r2 = 0x24;
		COMP(r2, r0);
		IF NE JUMP param_read.case_posttriglen; 
		r4 = dm(NOTRIGGERLEN);		
		jump param_read.sendevent;
		 	
	param_read.case_posttriglen:
		r2 = 0x25;
		COMP(r2, r0);
		IF NE JUMP param_read.case_filterlen; 
		r4 = dm(POSTTRIGLEN);		
		jump param_read.sendevent;
		 					
	param_read.case_downsample:
		r2 = 0x26;
		COMP(r2, r0);
		IF NE JUMP param_read.case_contlen; 
		r4 = dm(CODOWNSAMPLE);	
		jump param_read.sendevent; 
			
	param_read.case_contlen:
		r2 = 0x27;
		COMP(r2, r0);
		IF NE JUMP param_read.endcase; 
		r4 = dm(CONTLEN);  
		jump param_read.sendevent; 	
		
	param_read.error: 
		// this is where we'll send events
		// someday. 		
	
	param_read.sendevent: 

	
	// convert sender into bitmask
		r0 = 31; 
		comp(r0, r12); 
		if lt jump param_read.sendevent_tobitmask_high; 
		
		r6 = 0x01; 
		r0 = lshift r6 by r12;
		r1 = 0; 
		jump param_read.sendevent_tobitmask_done; 
		 
	param_read.sendevent_tobitmask_high: 
		r0 = 32; 
		r0 = r12 - r0; 
		r6 = 0x01; 
		r1 = lshift r6 by r0; 
		r0 = 0x00; 
		
	param_read.sendevent_tobitmask_done:		
		// r0, r1 already set
		r2 = 0x41;
		r3 = r13;
		// r4, r5 should already be set
	
		call write_event; 
		
	param_read.endcase:
	
		// what was that? 	
		rts; 	
		nop; 	
		
/*------------------------------------------------------
  acq_query: 
  	wrapper around the broadcast_acqstate
 	  	
	inputs: 
      
	outputs: 

	modifies:
		    
 -------------------------------------------------------*/
acq_query:
	call broadcast_acqstate;
	
	rts; 
	
		
/*------------------------------------------------------
  acq_set: 
  	sets the relevant acqboard parameters. 
  	requires the MYID conformance of MYID LSB:
  	   MYID LSB = 0 ==> we're DSP A
  	   MYID LSB = 1 ==> we're DSP B
  	   
	inputs: 
		standard event-in register set      
	outputs: 
		
		CMDIDPENDING;
		CMDPENDING; 
	modifies:
		    
 -------------------------------------------------------*/
acq_set: 
	r0 = dm(CMDIDPENDING); 
	r1 = -1; 
	comp(r0, r1); 
	if eq jump acq_set.pending_error; 
	
	
    r0 = FEXT r13 BY 8:8; // RO is target
    r1 = FEXT r13 by 0:8; // R1 is address

	acq_set.gain:
    r2 = 0; 
    comp(r2, r0); 
    if ne jump acq_set.filter;
    
    r2 = 4;
    comp(r2, r1); 
    if lt jump acq_set.gain_spike; 
    if eq jump acq_set.gain_cont; 
    if gt jump acq_set.gain_error; 
    
    acq_set.gain_spike:
    // spike channel gain setting; 
    r0 = dm(MYID); 
    //bit tst r0 	
    
    acq_set.gain_cont:
    // continuous channel gain setting;
    
    acq_set.gain_error:
    // invalid channel request
  	  
    
    acq_set.filter:
    
    
    
    
    //CMDIDPENDING = CMDID + 1;
     
    
	
	
	
acq_set.pending_error:

    r0 = FEXT r13 BY 8:8; // RO is target
    r1 = FEXT r13 by 0:8; // R1 is address
	
	
	rts; 
