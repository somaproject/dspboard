#ifndef HOSTDATAOUT
#define HOSTDATAOUT

#include <dataout.h>

class HostDataOut : public DataOut
{
  
public:
  HostDataOut(); 
  void sendData(Data_t &); 
  void sendPending(); 
  bool txBufferFull(); 
  unsigned char mostrecentbuffer[2000]; 
  int dataCount_; 
};

#endif 
