#include "eventrx.h"

EventRX * eventrx; 



extern "C" {

  void __attribute__((interrupt_handler)) ppirxisr() 
  {
    /* workaround for anomaly:
       05000257 - Interrupt/Exception During Short Hardware Loop May Cause Bad Instruction Fetches
    */
    __asm__("R0 = LC0;"
	    "LC0 = R0;"
	    "R0 = LC1;"
	    "LC1 = R0" 
	    : : : "R0" ); 

    eventrx->RXDMAdoneISR(); 

    short q = *pSIC_ISR;  // THIS HAS TO BE A SHORT FOR THE LOVE OF GOD

    // clear the relevant DMA bit? 
    *pDMA0_IRQ_STATUS |= 0x1; 

  }
  
} 



EventRX::EventRX() :
  currentReadBuffer_(0), 
  currentWriteBuffer_(0), 
  errorCount(0)
{
  // zero buffer
  for (int i = 0; i < BUFNUM * BUFLEN; i++) {
    buffer_[i] = 0; 
  }

  
}

void EventRX::setup()
{


  // zero memory
  for (int y = 0 ; y < BUFLEN * BUFNUM; y++) {
    buffer_[y] = 0;  
  }
  
  // disable PPI
  *pPPI_CONTROL = 0x0000; 
  // configure PPI DMA
  *pDMA0_CONFIG = 0x0000; 

  *pDMA0_PERIPHERAL_MAP = 0x0000; 
  

  *pDMA0_START_ADDR = &buffer_[0]; 
  *pDMA0_X_COUNT = BUFBURST;  // words
  *pDMA0_X_MODIFY = 0x02; // 
  *pDMA0_Y_COUNT = BUFNUM; // 
  *pDMA0_Y_MODIFY = BUFLEN * 2 - BUFBURST * 2 + 2; 
  *pDMA0_CURR_DESC_PTR = 0x00; 
  
  *pDMA0_CONFIG = 0x10D7;  // start dma, 2D, memory write operation
  
  *pPPI_COUNT = (BUFBURST*2)-1; 
  *pPPI_DELAY = 0x0000; 

  
}

void EventRX::start()
{


  // first, we configure the System Interrupt Controller
  
  // System interrupt Mask Register
  *pSIC_IMASK |= 0x00000100;  
  // DMA interrupt 0 enabled


  // System Interrupt Assignment Registers
  // This maps the System INterrupts to general-purpose interrupts. 

  // Map DMA0 (PPI) interrupt to IVG10 

  *pSIC_IAR1 |= 0x00000003; 

  // Core Event Controller Registers
  *pIMASK |= 0x0000041F; // IVG10
  
  *pPPI_CONTROL = 0x408D; 
  
}

void EventRX::stop() 
{
  *pPPI_CONTROL = 0x0000; 

}

bool EventRX::empty() 
{
  return (currentReadBuffer_ == currentWriteBuffer_);

}

uint16_t * EventRX::getReadBuffer()
{
  return &buffer_[BUFLEN *  currentReadBuffer_];
  
}

uint16_t * EventRX::doneReadBuffer()
{
  currentReadBuffer_ = (currentReadBuffer_+1) % BUFNUM; 

}


void EventRX::RXDMAdoneISR() {
  currentWriteBuffer_ = (currentWriteBuffer_ + 1) % BUFNUM; 
  if (currentWriteBuffer_ == currentReadBuffer_) {
    errorCount++; 
  }
}
