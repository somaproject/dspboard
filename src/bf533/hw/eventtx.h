#ifndef EVENTTX_H
#define EVENTTX_H

#include <event.h>


class EventTX
{
public: 
  EventTX(); 
  
  void newEvent(const EventTX_t & evt); 
  bool sendEvent(); 
  void setup(); 
  bool txBufferFull(); 

  private:
  static const int EVTBUFLEN = 10; 
  static const int BUFSIZE = 16; 
  static const unsigned short FIFOFULL_MASK = 0x0001; 
  //static const unsigned short DMA_RUN = 0x0008; 
  //static const unsigned short DMA_DONE = 0x0001; 

  //static uint16_t buffer_[EVTBUFLEN][BUFSIZE]; 
  static uint16_t buffer_[10][16]; 
  int nextFreeEvent_; 
  int nextSendEvent_; 
  void eventToDMABuffer(const EventTX_t & etx, uint16_t * tgtbuff); 
  
  bool txPending_; 

  void setupSPI(); 
  void setupDMA(); 
  void setupFPGAFIFOFlag(); 

  bool isFPGAFIFOFull(); 


}; 


#endif

