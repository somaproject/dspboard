#include <sinks/rawsink.h>

RawSink::RawSink(SystemTimer * st, DataOut * dout, unsigned char datasrc) : 
  pSystemTimer_(st), 
  pDataOut_(dout), 
  sink(fastdelegate::MakeDelegate(this, &RawSink::processSample)), 
  pendingPos_(0), 
  dataSource_(datasrc), 
  pendingRawData_(datasrc)
{
  // FIXME : Not really RAW-format compatible, but working on it


}

void RawSink::processSample(sample_t samp)
{
  pendingRawData_.buffer[pendingPos_] = samp; 
  if (pendingPos_ == RawData_t::BUFSIZE - 1) {
    // send the packet
    pDataOut_->sendData(pendingRawData_); 

    pendingPos_= 0; 
  } else {
    pendingPos_++; 
  }

}

