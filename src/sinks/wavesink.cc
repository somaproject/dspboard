#include <sinks/wavesink.h>
const uint16_t WaveSink::valid_downsample_N[] = {1, 2, 4, 8, 16, 32}; 
const uint32_t WaveSink::samprates_num[] = {ACQRATE/1,  ACQRATE/2, 
					   ACQRATE/4,  ACQRATE/8,
					   ACQRATE/16, ACQRATE/32}; 
const uint32_t WaveSink::samprates_den[] = {1, 1, 1, 1, 1, 1}; 


WaveSink::WaveSink(SystemTimer * st, DataOut * dout, EventDispatch *ed,
		   EventTX * etx, FilterLinkController * fl,
		   unsigned char datasrc) : 
  pSystemTimer_(st), 
  pDataOut_(dout), 
  pEventDispatch_(ed), 
  pEventTX_(etx),
  sink(fastdelegate::MakeDelegate(this, &WaveSink::processSample)),
  bufferPos_(0),
  dataSource_(datasrc), 
  pendingWaveData_(datasrc), 
  downSampleN_(1),
  downsamplepos_(downSampleN_ -1)
{
  bcastEventTX_.clear(); 
  bcastEventTX_.setall();   

  ed->registerCallback(ECMD_QUERY, fastdelegate::MakeDelegate(this, 
							 &WaveSink::query)); 

  ed->registerCallback(ECMD_SET, fastdelegate::MakeDelegate(this, 
							    &WaveSink::setstate)); 

  sampRateNumerator_ = 32000; 
  sampRateDenominator_ = 1; 

}

void WaveSink::processSample(sample_t data)
{
  // called at the end of each sample cycle
  // perform the actual work! 
  
  downsamplepos_ = (downsamplepos_ + 1) % downSampleN_; 

  if(downsamplepos_ != 0) {
    return; 
  }
  
  pendingWaveData_.data[bufferPos_] = data; 

  if(bufferPos_ == 0) {
    bufferStartTime_ = pSystemTimer_->getTime(); 
  }
  bufferPos_++; 
  if (bufferPos_ == WaveData_t::BUFSIZE) {
    sendWave(); 
    bufferPos_ = 0; 
  }
    
}

void WaveSink::abortCurrentPacket()
{
  // called any time any of the settings change, such that 
  // we never lose a packet. 

  // this means that settings changes might cost us already-recorded
  // data. 
  bufferPos_ = 0; 
  downsamplepos_ = downSampleN_ -1; 

}

void WaveSink::sendWave()
{
  // send the current spike

  // copy time

  pendingWaveData_.time = bufferStartTime_; 

  // copy samp rate num / denom
  pendingWaveData_.sampratenum = sampRateNumerator_;
  pendingWaveData_.samprateden = sampRateDenominator_; 
  pendingWaveData_.filterid = sink.pSource_->id; 
  pendingWaveData_.chansrc = chansrc_; 
  pDataOut_->sendData(pendingWaveData_); 
    
}


void WaveSink::query(dsp::Event_t * et){
  char param = et->data[0]; 
  switch(param) {
  case DOWNSAMPFACTOR: 
    sendDownSampleResponse(); 
    break; 
  case SAMPRATE: 
    sendSampleRateResponse(); 
    break; 
  case FILTERID: 
    sendFilterIDResponse(); 
    break; 
  default:
    break; 
  } 
  
}

void WaveSink::setstate(dsp::Event_t * et) {
  char param = et->data[0]; 
  
  switch(param) {
  case  DOWNSAMPFACTOR: 
    {
      uint16_t factor  = et->data[1]; 
      if (factor != downSampleN_) {
	bool valid = false; 
	char pos = 0; 
	for(char i = 0; i < 6; i++) {
	  if (valid_downsample_N[i] == factor) {
	    valid =true; 
	    pos = i; 
	    break; 
	  }
	}
	if (valid) { 
	  downSampleN_ = factor; 
	  sampRateNumerator_ = samprates_num[pos];
	  sampRateDenominator_ = samprates_den[pos];	     
	  abortCurrentPacket(); 
	} else { 
	  sendError(et, ERROR_INVALID_DOWNSAMPLE); 
	}
	
      }
      sendDownSampleResponse(); 
      sendSampleRateResponse(); 
    }
    break; 
  case FILTERID:
    {
      filterid_t filterid= (et->data[1] << 16) | (et->data[2]); 
      bool success = false; 
      success = sink.setFilterID(filterid); 
      if (!success) {
	sendError(et, ERROR_INVALID_FILTER_ID); 
      } else { 
	sendFilterIDResponse(); 
      }
    }
    break; 
  default:
    break; 
  }

  
}

 
void WaveSink::sendSampleRateResponse(){

  bcastEventTX_.event.cmd = ECMD_RESPONSE; 
  bcastEventTX_.event.src = pEventTX_->mysrc; 

  sampRateNumerator_ = 0; // FIXME:  LOOK UP TABLE. 
  sampRateDenominator_ = 0; // FIXME LOOKUP TABLE

  bcastEventTX_.event.data[0] = SAMPRATE; 
  bcastEventTX_.event.data[1] = sampRateNumerator_ >> 16; 
  bcastEventTX_.event.data[2] = sampRateNumerator_ & 0xFFFF; 

  bcastEventTX_.event.data[3] = sampRateDenominator_ >> 16; 
  bcastEventTX_.event.data[4] = sampRateDenominator_ & 0xFFFF; 

  pEventTX_->newEvent(bcastEventTX_); 
  
}

void WaveSink::sendDownSampleResponse(){

  bcastEventTX_.event.cmd = ECMD_RESPONSE; 
  bcastEventTX_.event.src = pEventTX_->mysrc; 

  bcastEventTX_.event.data[0] = DOWNSAMPFACTOR; 
  bcastEventTX_.event.data[1] = downSampleN_; 

  pEventTX_->newEvent(bcastEventTX_); 
  
}

void WaveSink::sendFilterIDResponse(){

  bcastEventTX_.event.cmd = ECMD_RESPONSE; 
  bcastEventTX_.event.src = pEventTX_->mysrc; 

  bcastEventTX_.event.data[0] = FILTERID; 
  filterid_t fid =0; 
  fid = sink.getFilterID(); 
  bcastEventTX_.event.data[1] = fid  >> 16; 
  bcastEventTX_.event.data[2] = fid & 0xFFFF; 
  
  pEventTX_->newEvent(bcastEventTX_); 
  
}

void WaveSink::sendError(dsp::Event_t * et, ERRORS)
{

  // FIXME


}
