#ifndef EVENTRX_H
#define EVENTRX_H
#include <cdefBF533.h>
#include <types.h>

class EventRX
{
public:
  EventRX(); 
  void setup(); 
  void start(); 
  void stop(); 
  bool empty(); 
  void RXDMAdoneISR(); 
  uint16_t * getReadBuffer();
  uint16_t * doneReadBuffer();
  uint16_t errorCount;
  //  uint16_t errorCount2;
private:
  static const short BUFNUM = 4; 
  static const short BUFLEN = 512; 
  static const short BUFBURST = 497; 

  uint16_t buffer_[BUFNUM * BUFLEN] __attribute__ ((aligned (4))); 
  uint16_t currentReadBuffer_; 
  uint16_t currentWriteBuffer_; 

  
  

}; 

extern EventRX * eventrx; 

#endif // EVENTRX
