#include "hostdataout.h" 

HostDataOut::HostDataOut() :
  dataCount_(0)
{

}

void HostDataOut::sendData(Data_t & d) 
{
  dataCount_++; 
  d.toBuffer(mostrecentbuffer); 

}

void HostDataOut::sendPending() {

}

bool HostDataOut::txBufferFull() {
  return false; 
}
