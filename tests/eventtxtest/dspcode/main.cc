/*
 *
 *
 */

#include <cdefBF533.h>
#include <hw/eventrx.h> 
#include <eventdispatch.h> 


int standalone_main()
{
  /* test without the EventRX component */

  int i = 0; 
  int k = 0; 
  int a, b, c, d, e, f, g, h; 
  
  unsigned short * buffer = new unsigned short[512*6]; 

  // zero memory
  for (int y = 0 ; y < 512*4; y++) {
    buffer[y] = 0;  
  }
  
  // disable PPI
  *pPPI_CONTROL = 0x0000; 
  // configure PPI DMA
  *pDMA0_CONFIG = 0x0000; 

  *pDMA0_PERIPHERAL_MAP = 0x0000; 
  
  int LEN = 1024;  // len is in  bytes
  int BURST = 994;  // burst is in bytes

  *pDMA0_START_ADDR = buffer; 
  *pDMA0_X_COUNT = BURST/2; 
  *pDMA0_X_MODIFY = 0x02; //  two-byte stride
  *pDMA0_Y_COUNT = 6; // 
  *pDMA0_Y_MODIFY = LEN - BURST + 2; // 30 
  *pDMA0_CURR_DESC_PTR = 0x00; 
  
  //*pDMA0_CONFIG = 0x0037;  // start dma, 2D, memory write operation
  *pDMA0_CONFIG = 0x0017;  // start dma, 2D, memory write operation
  
  *pPPI_COUNT = BURST-1; 
  *pPPI_DELAY = 0x0000; 

  *pPPI_CONTROL = 0x408D; 

  while(1) {

    int x; 

    x = x + 1; 
    
  }

  
}

class EventProc
{
public:
  EventProc() : eventpos(0) {
  }
  void eventrx(Event_t * et) {
    if (eventpos < 10) {
      events[eventpos] = *et; 
      eventpos++; 
    }
	
  }
  
  Event_t events[40]; 
  short eventpos; 

};


int objtest()
{
  eventrx = new EventRX(); 
  eventrx->setup(); 
  eventrx->start(); 
  
  int bufcnt = 0; 
  
  EventDispatch * ed = new EventDispatch(DSPA); 
  
    
  EventProc * ep = new EventProc; 
  ed->registerCallback(0x10, fastdelegate::MakeDelegate(ep, &EventProc::eventrx)); 
  
  
  while(1) {
    if (! eventrx->empty()){ 
      uint16_t * buf = eventrx->getReadBuffer(); 
      ed->parseECycleBuffer(buf); 
      while(ed->dispatchEvents())
	{
 	  // do nothing
	}

      eventrx->doneReadBuffer(); 
      bufcnt++; 
      if (bufcnt > 40) {
	eventrx->stop(); 
	bufcnt = 0; 
	
      }
    }
  }


}
int main()
{
  objtest(); 

}

