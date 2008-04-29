#include "hostdataout.h" 


HostDataOut::HostDataOut() :
  dataCount_(0)
{

}

void HostDataOut::sendData(Data_t & d) 
{
  dataCount_++; 
  d.toBuffer(mostrecentbuffer); 
  unsigned char * otherbuf = new unsigned char[2000]; 
  memcpy(otherbuf, mostrecentbuffer, 2000); 
  allbuffers.push_back(otherbuf); 


}

void HostDataOut::sendPending() {

}

bool HostDataOut::txBufferFull() {
  return false; 
}
