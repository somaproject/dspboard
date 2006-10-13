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

    q = *pSIC_ISR; 
    q = *pSIC_ISR; 
    q = *pSIC_ISR; 
    
  }
  

  void  __attribute__((interrupt_handler))  txisr()
  {
    int x = 0; 
    //as.TXDMAdoneISR();
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
  *pSIC_IMASK = 0x00000200;  // only "DMA 1 Interrupt (SPORT0 RX)" is enabled
  // note that this is simply DMA channel 1, and  could be associated
  // with any peripheral


  // System Interrupt Assignment Registers
  // This maps the System INterrupts to general-purpose interrupts. 

  // We map all to IVG7 except for DMA1, which we map to IVG8. 
  *pSIC_IAR0 = 0x00000000; 
  *pSIC_IAR1 = 0x00000010; 
  *pSIC_IAR2 = 0x00000000; 

  // Core Event Controller Registers
  *pIMASK = 0x0000013F; // IVG8, IVHW enabled; everything else masked
  
  
  
  as->start(); 
  
  short x = 0; 
  int correctsamples = 0; 
  int errorsamples = 0; 
  AcqFrame af[20]; 
  
  for (int i = 0; i < 20; i++)
    { 
      while (as->checkRxEmpty())
	{
	  // spin
	}
      // no longer empty, get the frame
      as->getNextFrame(&af[i]); 

    }
  // verify samples
  for (int i = 1; i < 20; i++)
    {
      unsigned char x1 = (af[i-1].samples[0] >> 8); 
      unsigned char x2 = (af[i].samples[0] >> 8); 
      if (x2 == (x1 + 1) ){
	correctsamples +=1; 
      } else
	errorsamples += 1; 
    }

  while(1){ 
  } 
  
}


