#include "eventtx.h"
#include <iostream>

EventTX::EventTX() :
  eventBuffer_()
{
  

}

bool EventTX::newEvent(const dsp::EventTX_t &evt)
{
  eventBuffer_.push_back(evt); 
  return true;
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

uint16_t EventTX::getFIFOFullCount()
{
  // This function only has utility in the physical hardware


  return 0x5678; 
}

uint16_t EventTX::getFPGAFullCount(){
  // Only useful in the physical hardware

  return 0x1234; 


}

