#ifndef HOSTDATAOUT
#define HOSTDATAOUT

#include <vector>

#include <dataout.h>

class HostDataOut : public DataOut
{
  
public:
  HostDataOut(); 
  static const int BUFSIZE=2000; 
  void sendData(Data_t &); 
  void sendPending(); 
  bool txBufferFull(); 
  unsigned char mostrecentbuffer[BUFSIZE]; 
  std::vector<unsigned char* > allbuffers; 
  int dataCount_; 
  void printBuffer(unsigned char * buffer) ; 

};

#endif 
