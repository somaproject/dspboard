#include "echoproc.h" 
#include <filter.h>
#include <hw/misc.h>
#include <hw/memory.h>

EventEchoProc::EventEchoProc(EventDispatch * ed, EventTX* etx, 
			     SystemTimer * ptimer, 
			     unsigned char device) : 
  eventpos(0), 
  petx(etx), 
  iterations(0),
  ptimer_(ptimer), 
  device_(device), 
  etx_errors(0)
{
  
  ed->registerCallback(0xF0, fastdelegate::MakeDelegate(this, 
							&EventEchoProc::eventEcho)); 
  
  ed->registerCallback(0xF2, fastdelegate::MakeDelegate(this, 
							&EventEchoProc::eventLED)); 
    
  ed->registerCallback(0xF4, fastdelegate::MakeDelegate(this, 
							&EventEchoProc::eventBenchQuery)); 
    
  ed->registerCallback(0xF6, fastdelegate::MakeDelegate(this, 
							&EventEchoProc::eventDebugQuery)); 

  ed->registerCallback(0xF8, fastdelegate::MakeDelegate(this, 
							&EventEchoProc::eventMemCheck)); 

    
  for (int i = 0; i < NUMBENCH; i++){
    latest_[i] = 0; 
    starttime_[i] = 0; 
    max_[i] = 0; 
    
  }
  
}

void EventEchoProc::eventEcho(dsp::Event_t * et) {
  dsp::EventTX_t etx ;
  etx.addr[0] = 0xF; 
  etx.event.cmd = 0xF1; 
  etx.event.src = device_;
  etx.event.data[0] = et->data[0]; 
  etx.event.data[1] = iterations; 
  somatime_t time = ptimer_->getTime(); 
  etx.event.data[2] = (time >> 32) & 0xFFFF;
  etx.event.data[3] = (time >> 16) & 0xFFFF;
  etx.event.data[4] = (time >> 0) & 0xFFFF;
  petx->newEvent(etx); 
  
  iterations++; 
  
}

void EventEchoProc::eventLED(dsp::Event_t * et) {
  
  if (et->data[0] > 0) {
    setEventLED(true); 
  } else {
    setEventLED(false); 
  }
  
}

void EventEchoProc::eventBenchQuery(dsp::Event_t * et) {
  dsp::EventTX_t etx ;
  etx.addr[0] = 0xF;  // FIXME Actually send to requester
  etx.event.cmd = 0xF5; 
  etx.event.src = device_;

  char chan = et->data[0]; 
  const int DATAFIFOFULL_MASK = 0x0010; 
  //etx.event.data[0] =  (*pFIO_FLAG_D & DATAFIFOFULL_MASK); 

  etx.event.data[1] = latest_[chan] >> 16; 
  etx.event.data[2] = latest_[chan] & 0xFFFF; 
  etx.event.data[3] = max_[chan] >> 16; 
  etx.event.data[4] = max_[chan] & 0xFFFF; 
  petx->newEvent(etx); 
  
}

void EventEchoProc::eventDebugQuery(dsp::Event_t * et) {
  /*
    Right now, this checks to see if we overflow the event buffer
    by sending the requested number of simultaneous event packets

  */ 


  dsp::EventTX_t etx ;
  etx.addr[0] = 0xF;  // FIXME Actually send to requester
  etx.event.cmd = 0xF7; 
  etx.event.src = device_;
  
  uint16_t reqnonce = et->data[0]; 
  uint16_t numtosend = et->data[1]; 
  for(char i = 0; i < numtosend; i++) {
    etx.event.data[0] =  reqnonce; 
    etx.event.data[1] =  i; 
    etx.event.data[2] = etx_errors; 
    etx.event.data[3] = petx->getFIFOFullCount(); 
    etx.event.data[4] = petx->getFPGAFullCount(); 
    if (! petx->newEvent(etx)) {
      etx_errors += 1; 
    }
  }
  
}

void EventEchoProc::benchStart(char counter)
{
  starttime_[counter] = cycles(); 
  
}

void EventEchoProc::benchStop(char counter)
{
  int delta = cycles() - starttime_[counter]; 
  
  latest_[counter] = delta; 
  if (delta > max_[counter]) {
    max_[counter] = delta; 
  }

}

void EventEchoProc::eventMemCheck(dsp::Event_t * et) {
  dsp::EventTX_t etx ;
  etx.addr[0] = 0xF; // FIXME actually send to requester
  etx.event.cmd = 0xF9; 
  etx.event.src = device_;
  uint32_t memamt = memory_in_use(); 
  
  etx.event.data[0] = memamt >> 16; 
  etx.event.data[1] = memamt & 0xFFFF; 
  somatime_t time = ptimer_->getTime(); 
  etx.event.data[2] = (time >> 32) & 0xFFFF;
  etx.event.data[3] = (time >> 16) & 0xFFFF;
  etx.event.data[4] = (time >> 0) & 0xFFFF;
  petx->newEvent(etx); 
  
}
