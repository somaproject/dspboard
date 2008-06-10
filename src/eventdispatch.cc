#include "eventdispatch.h"
//#include <cdefBF533.h>

EventDispatch::EventDispatch(DSP_POSITION dsppos) :
  dsppos_ (dsppos), 
  currentBuffer_(0)
{


  for (int i = 0; i < 256; i++) {
    cmdDispatch[i] = 0; 
  }
  
  
}

void EventDispatch::registerCallback(unsigned char pos, EventDispatchProc_t edp)
{
  cmdDispatch[pos]  = edp; 
  
}

void EventDispatch::parseECycleBuffer(uint16_t array[])
{
  currentBytePos_ = 0; 
  currentBuffer_ = array; 

}

bool EventDispatch::dispatchEvents()
{
  if (currentBytePos_ >= 10) {
    return false; 
  }

  uint8_t addrbyte; 
  if (dsppos_ == DSPA) {
    addrbyte = getAByte(currentBytePos_); 
  } else if (dsppos_ == DSPB) {
    addrbyte = getBByte(currentBytePos_); 
  } else if (dsppos_ == DSPC) {
    addrbyte = getCByte(currentBytePos_); 
  } else if (dsppos_ == DSPD) {
    addrbyte = getDByte(currentBytePos_); 
  }
  
  if (addrbyte != 0) {
    dispatchEventByte(currentBytePos_, addrbyte); 
  }
  currentBytePos_++; 
  
  return true; 
  
}

void EventDispatch::dispatchEventByte(uint8_t eventpos, uint8_t addrbyte)
{
  for (uint16_t apos = 0; apos < 8; apos++ ) {
    if ((addrbyte & (1 << apos)) != 0) {
      uint16_t * curbuf = &(currentBuffer_[24 + (apos + eventpos*8) * 6]); 
      Event_t evt;
      evt.clear(); 
      evt.cmd = (curbuf[0] >> 8) & 0xFF; 
      evt.src = curbuf[0] & 0xFF; 
      evt.data[0] = curbuf[1]; 
      evt.data[1] = curbuf[2]; 
      evt.data[2] = curbuf[3]; 
      evt.data[3] = curbuf[4]; 
      evt.data[4] = curbuf[5]; 
      if (cmdDispatch[evt.cmd] != 0 ) {
	cmdDispatch[evt.cmd](&evt); 
      }
    }
  }
  
}
