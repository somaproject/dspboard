/*
 *
 *
 */


#include <cdefBF533.h>
#include <bf533/acqserial.h> 
#include <bf533/memory.h> 

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
  

  void  __attribute__((interrupt_handler))  txisr()
  {


    as->TXDMAdoneISR();

    short q = *pDMA2_IRQ_STATUS; 
    *pDMA2_IRQ_STATUS = 0x1; 
    q = *pDMA2_IRQ_STATUS; 

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

int main()
{
  int i = 0; 
  int k = 0; 
  
   as = new AcqSerial(); 
   
  as->setupSPORT(); 
  as->setupDMA(); 

  // first, we configure the System Interrupt Controller
  
  // System interrupt Mask Register
  *pSIC_IMASK = 0x00000600;  
  // "DMA 1 Interrupt (SPORT0 RX)" and "DMA 2 Interrupt (SPORT0 TX)" enabled
  // note that this is simply DMA channel 1 or 2, and  could be associated
  // with any peripheral


  // System Interrupt Assignment Registers
  // This maps the System INterrupts to general-purpose interrupts. 

  // We map all to IVG7 except for DMA1, which we map to IVG8, 
  // and DMA2, which we map to IVG9
  *pSIC_IAR0 = 0x00000000; 
  *pSIC_IAR1 = 0x00000210; 
  *pSIC_IAR2 = 0x00000000; 

  // Core Event Controller Registers
  *pIMASK = 0x0000033F; // IVG8, IVG9, IVHW enabled; everything else masked
  
  
  
  as->start(); 
  
  short x = 0; 
  int correctsamples = 0; 
  int errorsamples = 0; 
  AcqFrame af[10]; 
   
  AcqCommand acqcmd; 
  acqcmd.cmd = 3; 
  acqcmd.cmdid = 6; 
  acqcmd.data = 0xAABBCCDD; 
  as->sendCommand(&acqcmd); 

  
  for (int i = 0; i < 10; i++)
    { 
      while (as->checkRxEmpty())
	{
	  // spin
	}
      // no longer empty, get the frame
      as->getNextFrame(&af[i]); 

     
    }
  
// verify samples
  for (int i = 1; i < 10; i++)
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

  acqSpinWait(as, 6); 

  for (int i = 0; i < 15; i++) {
    acqcmd.cmd = i / 4 + 1; 
    acqcmd.cmdid = i; 
    acqcmd.data = 0xAABBCCDD; 
    as->sendCommand(&acqcmd); 

    acqSpinWait(as, i); 
  }
  while(1){ 
    int i = 0; 
  } 
  
}


