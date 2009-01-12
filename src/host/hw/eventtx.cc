#include "eventtx.h"


EventTX::EventTX() :
  eventBuffer_()
{
  

}

void EventTX::newEvent(const dsp::EventTX_t &evt)
{
  eventBuffer_.push_back(evt); 

}

bool EventTX::txBufferFull() {
  return false; 
}

bool EventTX::sendEvent()
{

}

void EventTX::setup()
{

}

