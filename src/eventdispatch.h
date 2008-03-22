#ifndef EVENTDISPATCH_H
#define EVENTDISPATCH_H
#include "dsp.h"
#include "event.h"

#include "FastDelegate.h" 

typedef fastdelegate::FastDelegate1<Event_t *>  EventDispatchProc_t; 


class EventDispatch
{
  /* Perform even tdecode and dispatch */ 

public: 
  EventDispatch(DSP_POSITION dsppos); 
  void parseECycleBuffer(uint16_t array[]); 
  bool dispatchEvents(); 
  void registerCallback(unsigned char pos, EventDispatchProc_t edp);


private:
  EventDispatchProc_t cmdDispatch[256]; 
  DSP_POSITION dsppos_; 
  short currentBytePos_; 
  void dispatchEventByte(uint8_t eventpos, uint8_t addrbyte); 
  uint16_t * currentBuffer_; 
  

  inline uint8_t getAByte(uint8_t bytepos) {
    if (bytepos % 2 == 0) {
      return (currentBuffer_[1 + bytepos / 2] >> 8); 
    } else {
      return (currentBuffer_[1 + bytepos / 2] & 0xFF); 
    }
  }


  inline uint8_t getBByte(uint8_t bytepos) {
    if (bytepos % 2 == 0) {
      return (currentBuffer_[6 + bytepos/2] &  0xFF); 
    } else {
      return ((currentBuffer_[6 + 1 + bytepos/2] >> 8) &  0xFF); 
    }
  }

  inline uint8_t getCByte(uint8_t bytepos) {
    if (bytepos % 2 == 0) {
      return (currentBuffer_[12 + bytepos / 2] >> 8); 
    } else {
      return (currentBuffer_[12 + bytepos / 2] & 0xFF); 
    }

  }

  inline uint8_t getDByte(uint8_t bytepos) {
    if (bytepos % 2 == 0) {
      return (currentBuffer_[17 + bytepos/2] &  0xFF); 
    } else {
      return ((currentBuffer_[17 + 1 + bytepos/2] >> 8) &  0xFF); 
    }
  }


}; 


#endif // EVENTDISPATCH_H
