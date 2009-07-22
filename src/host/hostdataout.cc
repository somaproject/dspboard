#include "hostdataout.h" 
#include <iostream>
#include <string.h>

namespace dspboard { 

HostDataOut::HostDataOut() :
  dataCount_(0)
{

}

void HostDataOut::sendData(Data_t & d) 
{
  dataCount_++; 
  d.toBuffer(mostrecentbuffer); 
  unsigned char * otherbuf = new unsigned char[BUFSIZE]; 
  memcpy(otherbuf, mostrecentbuffer, BUFSIZE); 
  allbuffers.push_back(otherbuf); 
  
  
}

void HostDataOut::printBuffer(unsigned char * buffer) 
{
  for (int i = 0; i < BUFSIZE; i++) {
    printf("%2.2X ", (unsigned int)buffer[i]); 
    if (i % 16 == 15) {
      printf("\n"); 
    }
  }

}
void HostDataOut::sendPending() {

}

bool HostDataOut::txBufferFull() {
  return false; 
}

}
