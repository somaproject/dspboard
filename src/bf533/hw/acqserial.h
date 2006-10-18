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

  void RXDMAdoneISR(void); 
  void TXDMAdoneISR(void);   
private:
  
  static const int RXBUFLEN_ = 10; 
  
  unsigned short RXbuffer_[RXBUFLEN_ * 16]; 
  unsigned short EmptyTXBuffer_[16]; 
  unsigned short CommandTXBuffer_[16]; 
  
  int curRXpos_; 
  int curReadPos_; 
  bool txPending_; 
 

}; 
#endif // ACQSERIAL_H