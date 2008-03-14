#ifndef DATASPORT_H
#define DATASPORT_H

#include <types.h>

class Data_t {

public:
  virtual void toBuffer(unsigned char * ) = 0; 

};

class DataSPORT
{

 public:
  DataSPORT(); 
  void setup(); 
  void sendData(Data_t &); 
  void sendPending(); 
  bool txBufferFull(); 

 private:
  static const int DATABUFLEN = 4; 
  static const int BUFSIZE = 1024; 
  static const int DATAFIFOFULL_MASK = 0x0010; 

  uint8_t buffer_[DATABUFLEN][BUFSIZE]; 

  int nextFreeData_; 
  int nextSendData_; 
  bool txPending_; 

  void setupSPORT(); 
  void setupDMA(); 
  void setupFPGAFIFOFlag(); 
  bool isFPGAFIFOFull(); 
  bool isDMADone(); 

  void sendDataNum(int n); 

}; 


#endif // DATASPORT_H