#include <sinks/rawsink.h>
namespace dspboard { 

RawSink::RawSink(SystemTimer * st, DataOut * dout, 
		 unsigned char datasrc, unsigned char chansrc ) : 
  pSystemTimer_(st), 
  pDataOut_(dout), 
  sink(fastdelegate::MakeDelegate(this, &RawSink::processSample)), 
  pendingPos_(0), 
  dataSource_(datasrc), 
  pendingRawData_(datasrc, chansrc)
{
  // FIXME : Not really RAW-format compatible, but working on it
  
  pos = 0; 

}

void RawSink::processSample(sample_t samp)
{
  pendingRawData_.buffer[pendingPos_] = samp; 
  

  if (pendingPos_ == RawData_t::BUFSIZE - 1) {
    // send the packet
    pendingRawData_.time = pSystemTimer_->getTime(); 
    pDataOut_->sendData(pendingRawData_); 

    pos++; 

    pendingPos_= 0; 
  } else {
    pendingPos_++; 
  }

}

}
