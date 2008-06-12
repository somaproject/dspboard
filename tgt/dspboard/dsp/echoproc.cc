#include "echoproc.h" 
#include <filter.h>

EventEchoProc::EventEchoProc(EventDispatch * ed, EventTX* etx, 
			     SystemTimer * ptimer, 
			     unsigned char device) : 
  eventpos(0), 
  petx(etx), 
  iterations(0),
  ptimer_(ptimer), 
  device_(device)
{
  
  ed->registerCallback(0xF0, fastdelegate::MakeDelegate(this, 
							&EventEchoProc::eventEcho)); 
  
  ed->registerCallback(0xF2, fastdelegate::MakeDelegate(this, 
							&EventEchoProc::eventLED)); 
    
  ed->registerCallback(0xF4, fastdelegate::MakeDelegate(this, 
							&EventEchoProc::eventBenchQuery)); 
    
  for (int i = 0; i < NUMBENCH; i++){
    latest_[i] = 0; 
    starttime_[i] = 0; 
    max_[i] = 0; 
    
  }
  
}

void EventEchoProc::eventEcho(Event_t * et) {
  EventTX_t etx ;
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

void EventEchoProc::eventLED(Event_t * et) {
  
  *pFIO_DIR    |= 0x0100;
  if (et->data[0] > 0) {
    *pFIO_FLAG_D |= 0x0100;
  } else {
    *pFIO_FLAG_D &= ~0x0100;
  }
  
}

void EventEchoProc::eventBenchQuery(Event_t * et) {
  EventTX_t etx ;
  etx.addr[0] = 0xF;  // FIXME Actually send to requester
  etx.event.cmd = 0xF4; 
  etx.event.src = device_;

  char chan = et->data[0]; 
  etx.event.data[0] = chan; 
  etx.event.data[1] = latest_[chan] >> 16; 
  etx.event.data[2] = latest_[chan] & 0xFFFF; 
  etx.event.data[3] = max_[chan] >> 16; 
  etx.event.data[4] = max_[chan] & 0xFFFF; 
  petx->newEvent(etx); 
  
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
