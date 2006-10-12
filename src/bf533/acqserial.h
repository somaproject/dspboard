#ifndef ACQSERIAL_H
#define ACQSERIAL_H

#include <acqboardif.h>
#include <boost/array.hpp> 


class AcqSerial: public AcqSerialBase
{
public: 
  AcqSerial(); 
  ~AcqSerial(); 
  
  bool checkRxEmpty(); 
  bool getNextFrame(AcqFrame *); 
  bool sendCommand(const AcqCommand &); 

private:
  const int RXBUFLEN_ = 20; 

  uint16_t RXbuffer_[RXBUFLEN_ * 16]; 
  uint16_t EmptyTXBuffer_[16]; 
  uint16_t CommandTXBuffer_[16]; 
  
  int curPos_; 
  
}; 
#endif // ACQSERIAL_H
