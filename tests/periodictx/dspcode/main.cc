/*
 *
 *
 */


#include <cdefBF533.h>
#include <event.h>
#include <bf533/hw/eventtx.h>
#include <bf533/hw/datasport.h>

uint16_t htons(uint16_t x) {

  return (( x << 8) & 0xFF00) | ((x >> 8) & 0xFF); 
}

uint16_t htons_dma(uint16_t x) {

  return x; 
}


uint16_t  global_irq_status_read; 

class TestData : public Data_t
{
public:
  TestData(int num) : 
    num_(num) {}
  int num_; 

  void toBuffer(unsigned char *c) {
    // let's say our length is 128 bytes
    *c = 0x00; 
    c++; 
    *c = 128; 
    c++; 
    // now we copy
    
    // type
    *c = 0; 
    c++; 
    // source
    *c = 10; 
    c++

    for (int i = 0; i < 124; i++) {
      *c = i; 
      c++; 
    }

  } 
}; 

int main_loop()
{

  //etx.setup(); 
  EventTX * etx = new EventTX; 
  
  etx->setup(); 

  DataSPORT * pDataSPORT = new DataSPORT(); 
  pDataSPORT->setup(); 

  int iteration = 0; 
  int datatxcnt = 0; 

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
      et.event.data[1] = datatxcnt; 
      et.event.data[2] = 0x5566;
      et.event.data[3] = 0x7788;
      et.event.data[4] = 0x99AA;
      
    
      etx->newEvent(et); 
      iteration++; 
    }

    if(! pDataSPORT->txBufferFull()) {
      TestData td(0); 
      pDataSPORT->sendData(td); 
      datatxcnt++; 
    }
    
    etx->sendEvent(); 
    pDataSPORT->sendPending();     
  }


}

int main()
{

  main_loop(); 
  
}


