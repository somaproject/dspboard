#ifndef ACQSERIAL_H
#define ACQSERIAL_H

#include <acqboardif.h>

class AcqSerial : public AcqSerialBase
{
public: 
  AcqSerial(); 
  
  bool checkRxEmpty(); 
  void getNextFrame(AcqFrame *); 
  void sendCommand(AcqCommand *); 
  bool checkLinkUp(); 

  void setupSPORT(); 
  void setupDMA(); 
  void start();
  void stop(); 
  bool sendCommandDone();

  void RXDMAdoneISR(void); 
private:
  
  static const int RXBUFLEN_ = 10; 
  
  unsigned short RXbuffer_[RXBUFLEN_ * 16]; 
  unsigned short TXBuffer_[4]; 
  
  int curRXpos_; 
  int curReadPos_; 
  bool sendingTXBuffer_;
  int totalRXBufCnt_;
  bool linkUp() { return true;}

}; 
#endif // ACQSERIAL_H
