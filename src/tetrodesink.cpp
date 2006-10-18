#include <tetrodesink.hpp>

TetrodeSink::TetrodeSink(FilterLinkManager* flm, 
			 dsp.outInterface
			 ) : 
  outbuffers_(N_), 
  waveback_(6), 
  wavelen_(26),
  notrigger_(20)

{
  
  // create buffers

  // output possibilities
  for (int i = 0; i < outputDelayN_; i++)
    {
      outputdelays_[i] = -1; 
    }
  
  for (int i = 0; i < 4; i++) {
    filterLinks_[i] = NULL; 
  }

}



TetrodeSink::~TetrodeSink()
{

}

void setWaveParam(uint8_t waveback, uint8_t, wavelen)
{

  waveback_ = waveback; 
  wavelen_ = wavelen; 

}

void TetrodeSink::setThreshold(uint8_t chan, sample_t value) 
{

  threshold_[chan] = value; 

}

sample_t TetrodeSink::getThreshold(uint8_t chan)
{

  return threshold_[chan]; 

}

void TetrodeSink::newLink(char chan, int linkType, int inchan)
{
  if (filterLinks_[chan] != NULL)
    {
      delete filterLink_[chan]; 
      filterLink_[chan] = flm->newLink(linkType, inchan); 

    }

}

void TetrodeSink::sampleAcquire(void)
{

  for (char i = 0; i < 4; i++) {
    
    sample_t sample = 0; 
    

    if (filterLinks_[i] != NULL) {
      sample = filterLinks_[i]->nextSample(); 

      // place the output
      
      outBuffers_[i].append(sample);
      
      
      // threshold check
      if ( sample > threshold_[i] ) 
	{
	  bool trigger = true; 
	  for (char j = 0 ; j < outDelayN_; j++ ) 
	    {
	      if ( outputDelays_[j] ) > ( wavelen_ - waveback_ - notrigger_) 
		{
		  // if any of the output options are in a no
		  // trigger regime, don't trigger
		  trigger = false; 
		}
	    }
	  
	  if (trigger) {
	    // find the first non-zero output delay
	    for (char j = 0; j < outDelayN; j++ ) 
	      {
		if ( outputDelays_[j] < 0) {
		  outputDelays_[j] = wavelen_ - waveback_; 
		  break; 
		}
	      }
	  }
	}

    };

    


  }
  
}

bool TetrodeSink::checkPacketSend()
{
  bool sendcheck = false; 

  for (char j = 0; j < outDelayN; j++ ) 
    {
      if ( outputDelays_[j] == 0) {
	sendcheck = true; 
      }
      if (outputDelays_[j] >= 0)
	outputDelays_[j]--;
    }

  return sendcheck; 

}

void TetrodeSink::sendPacket(void)
{
  // create and send the relevant packet
  
  char* buffer = pDataOutput->requestNew(); 
  
  // perform manipulations
  

  buffer[0] = 0x01; 
  buffer[1] = dsp.src; 
  // the length of the channels
  uint16_t wavelenh = hosttonet(wavelen_); 
  memcpy(&buffer[2], wavelenh, 2); 
  
  uint64_t timestamph = hosttonet(dsp->getts()); 
  memcpy(&buffer[4], &timestamph+2, 6); 
  
  // output channels
  int32_t bytepos = 10; 
  
  for (char chan = 0; i < 4; i++) 
    {
      if (filterLinks_[chan] == NULL) {
	// do nothing, this channel not engaged
	buffer[bytepos] = 0; 
	bytepos++; 
	buffer[bytepos] = 0; 
	bytepos++; 

	bytepos += ((wavelenh_ + 1) * sizeof(sample_t)); 
	
      } else {
	buffer[bytepos] = filterLinks_[chan]->getChan(); 
	bytepos++; 
	buffer[bytepos] = filterLinks_[chan]->getID(); 
	bytepos++; 
	
	sample_t thold = hosttonet(threshold_[chan]); 
	memcpy(&buffer[bytepos], &thold, sizeof(sample_t)); 
	bytepos += 4; 
	
	outbuffers_[chan].linear_copy(&buffer[bytepos], wavelen_); 
	bytepos += wavelen_ * sizeof(sample_t); 

      }

    }

  // commit output 
  pDataOutput->commit(buffer); 
  
}

void TetrodeSink::sampleProcess(void) 
{
  sampleAcquire(); 
  if (checkPacketSend() ) 
    {
      sendPacket(); 
    }

}
