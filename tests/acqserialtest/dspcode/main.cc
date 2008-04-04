/*
 *
 *
 */


#include <cdefBF533.h>
#include <bf533/hw/acqserial.h> 
#include <bf533/hw/memory.h> 
#include "acqstatecontroltest.h" 

AcqSerial * as;  // global so we can get function wrappers

extern "C" {

  void __attribute__((interrupt_handler)) rxisr() 
  {
    as->RXDMAdoneISR(); 

    short q = *pSIC_ISR;  // THIS HAS TO BE A SHORT FOR THE LOVE OF GOD


    // clear the relevant DMA bit? 
    q = *pDMA1_IRQ_STATUS; 
    *pDMA1_IRQ_STATUS = 0x1; 
    q = *pDMA1_IRQ_STATUS; 

  }
  
} 

void acqSpinWait(AcqSerial * as, char cmdid)
{

  AcqFrame afCmdTest; 
  afCmdTest.cmdid = 0; 
  while (afCmdTest.cmdid != cmdid) {
    while (as->checkRxEmpty())
      {
	// spin
      }
    // no longer empty, get the frame
    as->getNextFrame(&afCmdTest); 
  }
}

void simpletest(AcqSerial * as)
{
  short x = 0; 
  int correctsamples = 0; 
  int errorsamples = 0; 
  const int AFNUM = 20; 
  AcqFrame *  af = new AcqFrame[AFNUM]; 
  for (int i = 0; i < AFNUM/2; i++)
    {
      for (int j = 0; j < 10; j++) {
	af[i].cmdid = 0; 
	af[i].mode = 0; 
	af[i].success = false; 
	af[i].loading = false; 
	af[i].samples[j] = 0x00; 
      }
    }


  // reset acqframe

  as->start(); 
  
  for (int i = 0; i < AFNUM; i++)
    { 
      while (as->checkRxEmpty())
	{
	}

      as->getNextFrame(&af[i]); 
    }

     
  AcqCommand acqcmd; 
  acqcmd.cmd = 7; 
  acqcmd.data = 0x00000000; 
  
  for (int i = 0; i < 10; i++) {
    for(int j = 0; j < 20000000; j++) {
      acqcmd.cmdid = i; 
     
    }
    as->sendCommand(&acqcmd); 
    while(! as->sendCommandDone() ) {
      int j = 10; 
      int k = 10; 
    }
    while(as->checkRxEmpty()) {
    }
    as->getNextFrame(&af[10+i]); 
    acqcmd.cmd = 7; 
    
  }

  while(1){ 
    int i = 0; 
  } 


// verify samples
  for (int i = 1; i < AFNUM; i++)
    {
      unsigned char x1 = (af[i-1].samples[0] >> 8); 
      unsigned char x2 = (af[i].samples[0] >> 8); 
      if (x2 == (x1 + 1) ){
	correctsamples +=1; 
      } else
	errorsamples += 1; 
    }

  for (int i = 0; i < 100000; i++){
    int j = 0; 
  }

  acqSpinWait(as, 3); 

   for (int i = 0; i < 15; i++) {
     acqcmd.cmd = 1; 
     acqcmd.cmdid = i; 
     acqcmd.data = 0x00000000; 
     as->sendCommand(&acqcmd); 

     acqSpinWait(as, i); 
     for(int j = 0; j < 100000000; j++) {
       acqcmd.cmdid = i; 
       
     }

     
   }
  while(1){ 
    int i = 0; 
  } 
  
  
}

int main()
{
  int i = 0; 
  int k = 0; 
  
  as = new AcqSerial(); 
   
  as->setup(); 

  // first, we configure the System Interrupt Controller
  
  // System interrupt Mask Register
  *pSIC_IMASK = 0x00000200;  
  // "DMA 1 Interrupt (SPORT0 RX)" and "DMA 2 Interrupt (SPORT0 TX)" enabled
  // note that this is simply DMA channel 1 or 2, and  could be associated
  // with any peripheral


  // System Interrupt Assignment Registers
  // This maps the System INterrupts to general-purpose interrupts. 

  // We map all to IVG7 except for DMA1, which we map to IVG8
  *pSIC_IAR0 = 0x00000000; 
  *pSIC_IAR1 = 0x00000010; 
  *pSIC_IAR2 = 0x00000000; 

  // Core Event Controller Registers
  *pIMASK = 0x0000033F; // IVG8, IVG9, IVHW enabled; everything else masked
  
  acqstatecontroltest1(as); 

  
}


