#include <rawsink.h>

RawSink::RawSink(int ID, FilterLinkManager * flm, 
		 SystemTimer * st, DataOutFifo * dof, 
		 EventOutFifo* eof) : 
  pFilterLinkManager_(flm), 
  pSystemTimer_(st), 
  pDataOutFifo_(dof), 
  pEventOutFifo_(eof), 
  ID_(ID), 
  fl_(NULL), 
  samplePos_(0)
{
  
  pOutBuffer_ = pDataOutFifo_.request();
  
}
  
void RawSink::newFilterLink(unsigned int type, int channel)
{
  if (fl_ != NULL) {
    delete fl_; 
  }
  
  fl_ = pFilterLinkManager_->newLink(type, channel); 
  
}

void RawSink::sampleProcess(void)
{
  if (fl_) 
    {
      sample_t x = fl_->nextSample(); 
      sample_t y = hostToNet(x); 
      
      memcpy(&pOutBuffer_[10 + sizeof(sample_t)*samplePos_], 
	     &y, sizeof(samplePos_)); 
      
      samplePos++; 

      if (samplePos_ == 128)
	{
	  sendBuffer(); 
	  samplePos_ = 0; 
	  
	}

    }
}

void RawSink::sendBuffer(void)
{

  // copy source
  // copy ID
  pOutBuffer_[0] = DATATYPE; 
  pOutBuffer_[1] = datasrc_; 
  short len = hostToNet(sizeof(sample_t) * sample_pos_ + 10); 

  memcpy(&pOutBuffer_[2], &len, sizeof(short)); 
  
  unsigned long ts = pSystemTimer->getTime(); 
  unsigned long tsnet = hostToNet(ts); 

  memcpy(&pOutBuffer_[4], &tsnet, 6); 
  
  pOutBuffer_->commit(); 
  
  pOutBuffer_ = pDataOutFifo_.request(); 
  

}
