    
    


/*--------------------------------------------------
  dispatch_event: main event loop
  calls read_event
  
  NO EVENT PROCESSING DONE HERE! Rather, jump to event_foo
  
  event_foo should jump back to dispatch_event_end
  
  
  
  
  -------------------------------------------------*/

  r0 = 0x10; 
  COMP(r0, r11);
  if EQ jump event_write; 
    
  r0 = 0x11; 
  COMP(r0, r11); 
  if EQ jump event_read; 
  
  r0 = 0x14;
  COMP(r0, r11);
  if EQ jump event_acqboard_set; 
   
  
  
dispatch_event_end:
// done with event
/*---------------------------------------------------
  readevent:
     returns a read-event from FPGA:
     r11 = command byte 
     r12 = sender
     r13 = data word 0 
     r14 = data word 2 | data word 1
     r15 = data word 4 | data word 3;
---------------------------------------------------*/

readevent:
	nop; 
	
		
/*-------------------------------------------------  
event_write: takes in standard event registers
     extracts TARGET, that is, what we're writing
     and ADDR, which is in most cases the address
     of a buffer, etc. 
--------------------------------------------------*/

event_write:
    r0 = FEXT r11 BY 0:8; // RO is target
    r1 = FEXT r11 by 8:8; // R1 is address
    

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
	r4 = SHLEN - 2; // make sure we're not trying to write too far
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
	r4 = SHLEN - 2; // make sure we're not trying to write too far
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
	r4 = SHLEN - 2; // make sure we're not trying to write too far
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
	r4 = SHLEN - 2; // make sure we're not trying to write too far
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
	r4 = COHLEN - 2; // make sure we're not trying to write too far
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

 
     