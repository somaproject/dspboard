#include "echoproc.h" 

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
    
  
  
}

void EventEchoProc::eventEcho(Event_t * et) {
  EventTX_t etx ;
  unsigned char addr =device_; 
  //    addr =  1 << ( et->src % 8) ; 
  //etx->addr[et->
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
