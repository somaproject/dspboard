#include <sinks/tspikesink.h>

TSpikeSink::TSpikeSink(SystemTimer * st, DataOut * dout, EventDispatch *ed,
		       EventTX * etx, FilterLinkController * fl,
		       unsigned char datasrc) : 
  pSystemTimer_(st), 
  pDataOut_(dout), 
  pEventDispatch_(ed), 
  pEventTX_(etx),
  sink1(fastdelegate::MakeDelegate(this, &TSpikeSink::processSample1)), 
  sink2(fastdelegate::MakeDelegate(this, &TSpikeSink::processSample2)), 
  sink3(fastdelegate::MakeDelegate(this, &TSpikeSink::processSample3)), 
  sink4(fastdelegate::MakeDelegate(this, &TSpikeSink::processSample4)), 
  samplesink(fastdelegate::MakeDelegate(this, &TSpikeSink::processSampleCycle)), 
  pendingPos_(0),
  pending_(0), 
  dataSource_(datasrc), 
  pendingTSpikeData_(datasrc)
{
  bcastEventTX_.clear(); 
  bcastEventTX_.setall();   

  ed->registerCallback(ECMD_QUERY, fastdelegate::MakeDelegate(this, 
							 &TSpikeSink::query)); 

  ed->registerCallback(ECMD_SET, fastdelegate::MakeDelegate(this, 
							    &TSpikeSink::setstate)); 
}

void TSpikeSink::processSample1(sample_t samp)
{
  // add channel 1
  pendingTSpikeData_.buffer[0][pendingPos_] = samp; 
  
}

void TSpikeSink::processSample2(sample_t samp)
{
  // add channel 2
  pendingTSpikeData_.buffer[1][pendingPos_] = samp; 
  
}

void TSpikeSink::processSample3(sample_t samp)
{
  // add channel 3
  pendingTSpikeData_.buffer[2][pendingPos_] = samp; 
}


void TSpikeSink::processSample4(sample_t samp)
{
  // add channel 4
  pendingTSpikeData_.buffer[3][pendingPos_] = samp; 
}


void TSpikeSink::processSampleCycle(char)
{
  // called at the end of each sample cycle
  // perform the actual work! 
  
  // check if any channels exceed threshold POSTTRIGGER
  // samples ago

  bool trigger = false; 

  char backpos = 0; 
  char backposm1 = 0; 

  
  // pendingPos_ points to most recent sample
  
  backpos = pendingPos_ - TSpikeData_t::POSTTRIGGER; 
  backposm1 = pendingPos_ - TSpikeData_t::POSTTRIGGER - 1; 
  if (backpos < 0) 
    {
      backpos += TSpikeData_t::BUFSIZE; 
    }
  
  if (backposm1 < 0) 
    {
      backposm1 += TSpikeData_t::BUFSIZE; 
    }
  
  if (pending_ > 0) {
    pending_--; 
  } else {
    // not currently pending
    if ((pendingTSpikeData_.buffer[0][backpos] > pendingTSpikeData_.threshold[0]
	 and pendingTSpikeData_.buffer[0][backposm1] <= pendingTSpikeData_.threshold[0]) or
	(pendingTSpikeData_.buffer[1][backpos] > pendingTSpikeData_.threshold[1]
	 and pendingTSpikeData_.buffer[1][backposm1] <= pendingTSpikeData_.threshold[1]) or
	(pendingTSpikeData_.buffer[2][backpos] > pendingTSpikeData_.threshold[2]
	 and pendingTSpikeData_.buffer[2][backposm1] <= pendingTSpikeData_.threshold[2]) or
	(pendingTSpikeData_.buffer[3][backpos] > pendingTSpikeData_.threshold[3]
	 and pendingTSpikeData_.buffer[3][backposm1] <= pendingTSpikeData_.threshold[3]))
      {
	pendingTSpikeData_.time = 
	  pSystemTimer_->getTime() - 
	  TSpikeData_t::POSTTRIGGER * samplesink.pSource_->samplerate / 50000; 
	pendingTSpikeData_.offset = pendingPos_; 

	sendSpike(); 
	pending_ = TSpikeData_t::PENDINGDELAY; 
      }
  }
  pendingPos_ = (pendingPos_ + 1) % TSpikeData_t::BUFSIZE; 
  
}

void TSpikeSink::sendSpike()
{
  // send the current spike
  
  // set the filterID
  pendingTSpikeData_.filterid[0] = sink1.pSource_->id; 
  pendingTSpikeData_.filterid[1] = sink2.pSource_->id; 
  pendingTSpikeData_.filterid[2] = sink3.pSource_->id; 
  pendingTSpikeData_.filterid[3] = sink4.pSource_->id; 

  pDataOut_->sendData(pendingTSpikeData_); 
  
  
}



void TSpikeSink::setThreshold(char chan, int32_t value){
  pendingTSpikeData_.threshold[chan] = value; 

}

int32_t TSpikeSink::getThreshold(char chan){
  return pendingTSpikeData_.threshold[chan]; 
}

void TSpikeSink::query(dsp::Event_t * et){
  char param = et->data[0]; 
  char channel = et->data[1]; 
  switch(param) {
  case  THRESHOLD: 
    sendThresholdResponse(channel); 
    break; 
  default:
    break; 
  } 
  
  
}

void TSpikeSink::setstate(dsp::Event_t * et) {
  char param = et->data[0]; 
  uint16_t channel = et->data[1]; 
  
  switch(param) {
  case  THRESHOLD: 
    {
      uint32_t thold = (et->data[2] << 16) | (et->data[3]); 
      pendingTSpikeData_.threshold[channel] = thold; 
      sendThresholdResponse(channel); 
    }
    break; 

  default:
    break; 
  }

  
}

 
void TSpikeSink::sendThresholdResponse(char chan){

  bcastEventTX_.event.cmd = ECMD_RESPONSE; 
  bcastEventTX_.event.src = pEventTX_->mysrc; 

  bcastEventTX_.event.data[0] = THRESHOLD; 
  bcastEventTX_.event.data[1] = chan; 
  
  bcastEventTX_.event.data[2] = pendingTSpikeData_.threshold[chan] >> 16; 
  bcastEventTX_.event.data[3] = pendingTSpikeData_.threshold[chan] & 0xFFFF; 

  pEventTX_->newEvent(bcastEventTX_); 

  
}
