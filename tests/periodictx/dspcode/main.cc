/*
 *
 *
 */


#include <cdefBF533.h>
#include <event.h>
#include <bf533/hw/eventtx.h>

uint16_t htons(uint16_t x) {

  return (( x << 8) & 0xFF00) | ((x >> 8) & 0xFF); 
}

uint16_t htons_dma(uint16_t x) {

  return x; 
}


uint16_t  global_irq_status_read; 

int eventtx_object_main()
{

  //etx.setup(); 
  EventTX * etx = new EventTX; 
  
  etx->setup(); 
  int iteration = 0; 

  while (1) {

    for (int j = 0; j < 10000000; j++) {
      // wait for a looong time

    }

    int read = *pFIO_FLAG_D; 

    if ( ! etx->txBufferFull()) { 
      EventTX_t et; 
      for (int z = 0; z < 10; z++) {
	et.addr[z] = 0xFF; // send to everyone. Every. One.  
      }
      
      et.event.cmd = 0xFF;  
      et.event.src = 0xAB; 
      et.event.data[0] = iteration; 
      et.event.data[1] = 0x3344;
      et.event.data[2] = 0x5566;
      et.event.data[3] = 0x7788;
      et.event.data[4] = 0x99AA;
      
    
      etx->newEvent(et); 
      iteration++; 
    }
    int i = *pDMA5_IRQ_STATUS; 
    
    etx->sendEvent(); 
  }
}

int main()
{

  eventtx_object_main(); 
  
}


