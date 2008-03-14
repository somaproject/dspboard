#include "eventtx.h"
#include <cdefBF533.h>


uint16_t EventTX::buffer_[10][16]; 

EventTX::EventTX() :
  nextFreeEvent_(0), 
  nextSendEvent_(0), 
  txPending_(false)
{
  

}

void EventTX::newEvent(const EventTX_t &evt)
{
  // copy to the next free buffer
  if (txBufferFull()) {
    // should throw event-output-fifo-error
  }

  eventToDMABuffer(evt, &buffer_[nextFreeEvent_][0]); 
  nextFreeEvent_ = (nextFreeEvent_+1) % EVTBUFLEN; 

}

bool EventTX::txBufferFull() {
  if (((nextFreeEvent_ + 2) % EVTBUFLEN) == nextSendEvent_) {
    return true; 
  }
  return false; 
}

void EventTX::eventToDMABuffer(const EventTX_t & etx, uint16_t * tgtbuff) {
  // copy the data into the correct order
  // note buffer must be of correct length, and 2-byte-aligned
  
  char * p = (char*)tgtbuff; 
  
  for (int i = 0; i < 5; i++) {
    *p = etx.addr[i * 2 + 1]; 
    p++; 
    *p = etx.addr[i * 2 + 0]; 
    p++; 
  }
  
  
  *p = etx.event.src; 
  p++; 

  *p = etx.event.cmd; 
  p++; 
  
  for (int i = 0; i < 5; i++)
    {
      uint16_t s = etx.event.data[i]; 
      *(uint16_t *)p =s; 
      p+= 2; 
    }
  
}

bool EventTX::sendEvent()
{
  
  if(txPending_) {
    if ( !(*pDMA5_IRQ_STATUS & DMA_DONE) ) {
      // not done yet, just return
      return false; 
    } else {
      // done! 
      *pDMA5_IRQ_STATUS = 0x01; // clear IRQ status
      txPending_ = false; 
    }
    
  }
  // txpending should be false, we are done. 
  for (int i = 0; i < 10; i++) {
    // race condition in waiting for full buffer
  }
  // check if the fifo is full 
  if (isFPGAFIFOFull()){
    return false; 
  }
  if (nextSendEvent_ != nextFreeEvent_) {
    // check for empty 
    
    *pDMA5_START_ADDR =  &buffer_[nextSendEvent_][0]; 
    *pDMA5_CONFIG |= 1; // start actual DMA activity
    nextSendEvent_ = (nextSendEvent_ + 1) % EVTBUFLEN; 
    txPending_ = true; 
  }
  
  return txPending_; 

}

void EventTX::setup()
{
  setupDMA(); 
  setupSPI(); 
  setupFPGAFIFOFlag(); 

}

void EventTX::setupSPI()
{
  *pSPI_FLG = 0xFF02; 

  *pSPI_BAUD = 4; 
  *pSPI_CTL = 0x0040; 
  *pSPI_CTL = 0x5903; // correct


}

void EventTX::setupFPGAFIFOFlag()
{
  // set the flag
  *pFIO_DIR    &= ~FIFOFULL_MASK; 
  *pFIO_INEN   |= FIFOFULL_MASK; 

}


void EventTX::setupDMA()
{
  *pDMA5_PERIPHERAL_MAP = 0x5000; 

  // Set up the DMA channel, by default, channel 5 is SPI
  *pDMA5_NEXT_DESC_PTR = 0; 
  *pDMA5_CURR_DESC_PTR = 0; 
  *pDMA5_START_ADDR = 0; 

  *pDMA5_X_COUNT = 11; 
  *pDMA5_X_MODIFY = 2; 

  *pDMA5_Y_COUNT = 0; 
  *pDMA5_Y_MODIFY = 0; 

  //*pDMA5_CONFIG = 0x0024; 
  *pDMA5_CONFIG = 0x00A4; 

}

bool EventTX::isFPGAFIFOFull()
{
  // read the relevant line 
  return (*pFIO_FLAG_D & FIFOFULL_MASK); 

}
