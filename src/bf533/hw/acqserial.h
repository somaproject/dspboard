#ifndef DSPBOARD_ACQSERIAL_H
#define DSPBOARD_ACQSERIAL_H

#include <hw/uarttx.h>
#include <acqboardif.h>

namespace dspboard { 

class AcqSerial : public AcqSerialBase
{
public: 
  AcqSerial(); 
  
  bool checkRxEmpty(); 
  void getNextFrame(AcqFrame *); 
  void sendCommand(AcqCommand *); 
  bool checkLinkUp(); 

  void setup(); 
  void setupLink(); 
  void setupSPORT(); 
  void setupDMA(); 
  void start();
  void stop(); 
  bool sendCommandDone();

  void inline RXDMAdoneISR(void)
  {
    __asm__("R0 = LC0;"
	    "LC0 = R0;"
	    "R0 = LC1;"
	    "LC1 = R0" 
	    : : : "R0" ); 


    curRXpos_ = (curRXpos_ +1) % RXBUFLEN_; 
    totalRXBufCnt_++; 
  }
private:
  
  static const int RXBUFLEN_ = 10; 
  static const short FIBERLINKUP_MASK = 0x0004; 
  
  
  unsigned short RXbuffer_[RXBUFLEN_ * 16] __attribute__ ((aligned (4))); 
  unsigned short TXBuffer_[4] __attribute__ ((aligned (4))); 
  
  int curRXpos_; 
  int curReadPos_; 
  bool sendingTXBuffer_;
  int totalRXBufCnt_;
  bool linkUp() { return true;}
  UARTTX pUARTTX_; 
  
}; 

}

#endif // ACQSERIAL_H
