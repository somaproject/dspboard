/*
 *
 *
 */


#include <cdefBF533.h>
#include <event.h>
#include <hw/eventtx.h>
#include <hw/eventrx.h>
#include <eventdispatch.h>

class EventEchoProc
{
public:
  EventEchoProc(EventTX* etx) : 
    eventpos(0), 
    petx(etx), 
    iterations(0)
  {
    
  }

  void eventTimeRX(Event_t * et) {
    if (et->src == 0) {
      time[0] = et->data[0]; 
      time[1] = et->data[1]; 
      time[2] = et->data[2]; 
    }
  }
  
  void eventEcho(Event_t * et) {
    EventTX_t etx ;
    unsigned char addr = 0; 
    //    addr =  1 << ( et->src % 8) ; 
    //etx->addr[et->
    etx.addr[0] = 0xF; 
    etx.event.cmd = 0xF1; 
    etx.event.src = 0x08; 
    etx.event.data[0] = et->data[0]; 
    etx.event.data[1] = iterations; 
    etx.event.data[2] = time[0]; 
    etx.event.data[3] = time[1]; 
    etx.event.data[4] = time[2]; 
    petx->newEvent(etx); 

    iterations++; 
    
  }
  
  short eventpos; 
  EventTX* petx; 
  short time[3]; 
  short iterations; 

};




int main_loop()
{

  EventTX * etx = new EventTX; 
  
  etx->setup(); 

  eventrx = new EventRX(); 
  eventrx->setup(); 

  EventDispatch * ed = new EventDispatch(DSPA); 
  
  EventEchoProc * eep = new EventEchoProc(etx); 

  ed->registerCallback(0x10, fastdelegate::MakeDelegate(eep, 
							&EventEchoProc::eventTimeRX)); 
  
  ed->registerCallback(0xF0, fastdelegate::MakeDelegate(eep, 
							&EventEchoProc::eventEcho)); 

  

  eventrx->start(); 

  while (1) {

    if (! eventrx->empty()){ 
      uint16_t * buf = eventrx->getReadBuffer(); 
      ed->parseECycleBuffer(buf); 
      while(ed->dispatchEvents())
	{
 	  // do nothing, dispatch all the evnets
	}
      eventrx->doneReadBuffer(); 
      
    }
    
    etx->sendEvent(); 
    
    
  }


}

int main()
{

  main_loop(); 
  
}


