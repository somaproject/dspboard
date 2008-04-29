#ifndef HOSTDATAOUT
#define HOSTDATAOUT

#include <vector>

#include <dataout.h>

class HostDataOut : public DataOut
{
  
public:
  HostDataOut(); 
  void sendData(Data_t &); 
  void sendPending(); 
  bool txBufferFull(); 
  unsigned char mostrecentbuffer[2000]; 
  std::vector<unsigned char* > allbuffers; 
  int dataCount_; 
};

#endif 
