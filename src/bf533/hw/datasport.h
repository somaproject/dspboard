#ifndef DATASPORT_H
#define DATASPORT_H

#include <types.h>
#include <dataout.h>


class DataSPORT : public DataOut
{

 public:
  DataSPORT(); 
  void setup(); 
  void sendData(Data_t &); 
  void sendPending(); 
  bool txBufferFull(); 

 private:
  static const int DATABUFLEN = 6; 
  static const int BUFSIZE = 1024; 
  static const int DATAFIFOFULL_MASK = 0x0010; 

  static uint8_t buffer_[DATABUFLEN][BUFSIZE]  __attribute__ ((aligned (8))); 

  unsigned short nextFreeData_; 
  unsigned short nextSendData_; 
  bool txPending_; 

  void setupSPORT(); 
  void setupDMA(); 
  void setupFPGAFIFOFlag(); 
  bool isFPGAFIFOFull(); 
  bool isDMADone(); 
  bool isSPORTHoldRegEmpty(); 

  void sendDataNum(int n); 
  int delay_; 


}; 


#endif // DATASPORT_H
