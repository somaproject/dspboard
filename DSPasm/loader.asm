#include <def21262.h>


.extern EVENTIN;
.extern EVENTOUT;
.extern MYID; 

.SECTION/PM seg_loader;
	// our lame attempt at a loader; 
	// keep in mind that this is loaded at 0x80000, but
	// execution begins at 0x80005, hence lots of initial nops
	nop;
	nop;
	nop;
	nop;
	nop; 
loader_copy:

	// first, we copy ourselves to far memory
	i8 = 0x80000; // base location
	i9 = 0x84100; // target location // debug
	m8 = 1; 
	lcntr = 256; do (pc, 3) UNTIL LCE; 	// loop 256 times
		px = pm(i8, m8); 
		pm(i9, m8) = px; 
		nop; 
		nop;
	jump loader_copy_done;

loader_copy_done:	 // we arrive here following the
					 // jump
					 
	nop;
	nop;  
// dma read to disable boot mode


	ustat3 = PPDUR23 | PPBHC | PPEN | PPDEN;
	ustat4 = PPDUR23 | PPBHC ; 
	
	dm(PPCTL) = ustat4; 
	
	r0 = EVENTIN;	dm(IIPP) = r0; 	// dummy point
	r0 = 1;			dm(IMPP) = r0; 

	r0 = 1;			dm(ICPP) = r0; 
	r0 = 1; 		dm(EMPP) = r0; 
	r0 = 0xF00000;	dm(EIPP) = r0; 
	r0 = 4;			dm(ECPP) = r0; 
	
	dm(PPCTL) = ustat3; 	
	

	ustat4 = dm(PPCTL); 
	bit tst ustat4 PPDS;  // poll for dma status 
	if tf jump (pc, -2); 
	

	bit set flags FLG0O;  // DEBUGGING
	bit clr flags FLG3O; // flag 3 input

	
loader_event_loop: // loader event read cycle
	if not flag3_in jump loader_event_loop; 
	
	call loader_read_event; 
	
	r2 = 0x05; 
	COMP(r2, r11);
	IF EQ JUMP loader_event_writemem; 

	r2 = 0x06; 
	COMP(r2, r11);
	IF EQ JUMP loader_event_boot; 
	
	// else there's no event!
	
	
	
	jump loader_event_loop; 
	

	
loader_event_writemem: 
	// write the input word into memory
	r0 = 0x80000; 
	r0 = r0 + r13; 
	
	bit set flags FLG0; 
	bit clr flags FLG0; 
	
	// r1 is upper 2 words
	r1 = fdep r15 by 16:16; 
	r2 = fext r14 by 16:16; 
	r1 = r1 or fdep r2 by 0:16; 
	
	r2 = fdep r14 by 16:16;
	
	PX2 = r1;	// assemble the event words into 
	PX1 = r2; 	// the instructing word
	
	i8 = r0; 
	r0 = 0;
	m8 = r0; 
	pm(i8, m8) = PX; 
	
	// write done
	
	
	// convert sender into bitmask
	r0 = 31; 
	comp(r0, r12); 
	if lt jump loader_event_writemem_highsender; 
	
	r5 = 0x01; 
	r0 = lshift r5 by r12;
	r1 = 0; 
	jump loader_event_writemem_done; 
	 
loader_event_writemem_highsender:
	r0 = 32; 
	r0 = r12 - r0; 
	r5 = 0x01; 
	r1 = lshift r5 by r0; 
	r0 = 0x00; 
	
loader_event_writemem_done:		
	r2 = 0x06; // command
	// copy packet
	r5 = r15;
	r4 = r14;
	r3 = r13; 
	call loader_write_event; 
	
	jump loader_event_loop; 
	
	
	
loader_event_boot:
	// actually begin the booting process; 
	
	
	nop;
	nop;
	nop;
	nop; 
	nop;
	nop;
	nop; 
loader_PP_ISR: RTI;
	nop; 
	nop;
	nop;
	nop;
	nop; 
loader_PP_ISR2: RTI;
	nop; 
	nop;
	nop;
	nop;


/*---------------------------------------------------
  loader_read_event:
     returns a read-event from FPGA:
     r11 = command byte 
     r12 = sender
     r13 = data word 0 
     r14 = data word 2 | data word 1
     r15 = data word 4 | data word 3;
---------------------------------------------------*/

loader_read_event:
	ustat3 = PPDUR20 | PPBHC | PP16 | PPEN | PPDEN;
	ustat4 = PPDUR20 | PPBHC | PP16; 
	
	dm(PPCTL) = ustat4; 
	
	r0 = EVENTIN; 	dm(IIPP) = r0; 	// starting point
	r0 = 1;			dm(IMPP) = r0; 

	r0 = 4;			dm(ICPP) = r0; 
	r0 = 1; 		dm(EMPP) = r0; 
	r0 = 0x6000;	dm(EIPP) = r0; 
	r0 = 8;			dm(ECPP) = r0; 

	
	
	dm(PPCTL) = ustat3; 
	
	nop;
	nop;
loader_read_event_wait:
	ustat4 = dm(PPCTL); 
	bit tst ustat4 PPDS;  // poll for dma status 
	if tf jump loader_read_event_wait; 
	
	r0 = dm(EVENTIN); 
	r11 = FEXT r0 BY 0:8;
	r12 = FEXT r0 BY 8:8;
	r13 = FEXT r0 BY 16:16;
	r14 = dm(EVENTIN+1);
	r15 = dm(EVENTIN+2); 
	
	rts; 


/*---------------------------------------------------
  loader_write_event:
     writes an event to the event bus:
     r0 =  address bits 31:0
     r1 =  address bits 47:32 (in LSBs)
     r2 =  command (8 lower bits)
     r3 =  data word 1
     r4 =  dw 3 | 2
     r5 = dw 5 | 4; 
     
---------------------------------------------------*/

loader_write_event:
	
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
	r0 = 0x4000;	dm(EIPP) = r0; 
	r0 = 10;		dm(ECPP) = r0; 

	
	
	nop;
	nop;
loader_write_event_wait:
	dm(PPCTL) = ustat3; 
	ustat4 = dm(PPCTL); 
	bit tst ustat4 PPDS;  // poll for dma status 
	if tf jump loader_write_event_wait; 
	
	
	
	rts;    		
	