#include "audiomon.h"

namespace dspboard {


AudioMonitor::AudioMonitor(EventDispatch * ed, EventTX * etx, DSPConfig * conf) :
  sink1(fastdelegate::MakeDelegate(this, &AudioMonitor::processSample1)),
  sink2(fastdelegate::MakeDelegate(this, &AudioMonitor::processSample2)),
  sink3(fastdelegate::MakeDelegate(this, &AudioMonitor::processSample3)),
  sink4(fastdelegate::MakeDelegate(this, &AudioMonitor::processSample4)),
  sinkC(fastdelegate::MakeDelegate(this, &AudioMonitor::processSampleC)),
  ed_(ed), 
  etx_(etx), 
  enabled_(false), 
  chansel_(0),
  samplepos_(0)
{
  
  // link the outputs
  ed->registerCallback(AUDIO_COMMAND, fastdelegate::MakeDelegate(this, 
								 &AudioMonitor::command)); 
  
  bcastEventTX_.clear(); 
  bcastEventTX_.setall();   
  bcastEventTX_.event.src = conf->getEventDevice(); 
  bcastEventTX_.event.cmd = AUDIO_OUTPUT_CMD; 


}

void AudioMonitor::processSample1(sample_t s) 
{
  if (enabled_) { 
    if (chansel_ == 0) { 
      processSample(s); 
    }
  }
  
}


void AudioMonitor::processSample2(sample_t s) {

  if (enabled_) { 
    if (chansel_ == 1) { 
      processSample(s); 
    }
  }
  

}

void AudioMonitor::processSample3(sample_t s) {

  if (enabled_) { 
    if (chansel_ == 2) { 
      processSample(s); 
    }
  }
  

}

void AudioMonitor::processSample4(sample_t s) {

  if (enabled_) { 
    if (chansel_ == 3) { 
      processSample(s); 
    }
  }
  

}

void AudioMonitor::processSampleC(sample_t s) {

  if (enabled_) { 
    if (chansel_ == 4) { 
      processSample(s); 
    }
  }
  

}


void AudioMonitor::processSample(sample_t s) {
  samples_[samplepos_] = s;

  if(samplepos_ == 3)  {
    bcastEventTX_.event.data[0] = 1; 
    // This is a hack to let us send 4 samples per ecycle, by pulling
    // off the most interesting 16 bits. FIXME 
    bcastEventTX_.event.data[1] = samples_[0] >> 8;  
    bcastEventTX_.event.data[2] = samples_[1] >> 8; 
    bcastEventTX_.event.data[3] = samples_[2] >> 8;
    bcastEventTX_.event.data[4] = samples_[3] >> 8; 
    
    etx_->newEvent(bcastEventTX_); 
  }


  if (samplepos_ == 3) {
    samplepos_ = 0; 
  } else  {
    samplepos_ ++; 
  }
  
  
}


void AudioMonitor::command(dsp::Event_t* et) {
  if (et->data[0] == 1) { 
    if (et->data[1] == 1) {
      enabled_ = true; 
    } else { 
      enabled_ = false; 
    }

    if(et->data[2] < 5) { 
      chansel_ = et->data[2]; 
    }

    // now send the state change update
    bcastEventTX_.event.data[0] = 0; 
    bcastEventTX_.event.data[1] = enabled_; 
    bcastEventTX_.event.data[2] = chansel_; 
    etx_->newEvent(bcastEventTX_); 
    
  }

}




}
