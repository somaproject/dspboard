#include <sinks/stimsink.h>

namespace dspboard {


StimSink::StimSink(EventDispatch *ed,
		   EventTX * etx, 
		   unsigned char datasrc) : 
  pEventDispatch_(ed), 
  pEventTX_(etx),
  sink(fastdelegate::MakeDelegate(this, &StimSink::processSample)),
  dataSource_(datasrc), 
  enabled_(false), 
  threshold_(0), 
  lastdata_(0)
{
  eventTX_.clear(); 
  eventTX_.set(SRC_DIGITAL_OUT); 
  eventTX_.event.cmd = ECMD_DIGITAL_WRITE; 
  eventTX_.event.data[0] = 0xFFFF; 
  eventTX_.event.data[1] = 0xFFFF; 
  eventTX_.event.data[2] = 0; 
  eventTX_.event.data[3] = 0; 
 
  //bcastEventTX_.setall();   

  ed->registerCallback(ECMD_ENABLE, fastdelegate::MakeDelegate(this, 
							 &StimSink::setstate)); 


}

void StimSink::processSample(sample_t data)
{
  // called at the end of each sample cycle
  // perform the actual work! 

  if (! enabled_)
    return; 
  
  if ((data > threshold_ ) and (lastdata_ <= threshold_)) { 
    // send two events !
    eventTX_.event.data[2] = 0xFFFF; 
    eventTX_.event.data[3] = 0xFFFF; 
    pEventTX_->newEvent(eventTX_); 

    eventTX_.event.data[2] = 0;
    eventTX_.event.data[3] = 0; 
    pEventTX_->newEvent(eventTX_); 
  }

  lastdata_ = data; 

    
}
void StimSink::setstate(dsp::Event_t * et) {
  char param = et->data[0]; 
  
  if( param == 0) {
    enabled_ = false; 
  } else {
    enabled_ = true; 
    threshold_ = et->data[1]; 
    threshold_ = (threshold_ << 16) | et->data[2]; 
  }

}

 

}
