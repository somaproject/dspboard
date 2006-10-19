#include <sinks/rawsink.h>
#include <hw/byteswap.h>

RawSink::RawSink(int ID, FilterLinkManager * flm, 
		 SystemTimer * st, DataOutFifo * dof, 
		 EventOutFifo* eof) : 
  pFilterLinkManager_(flm), 
  pSystemTimer_(st), 
  pDataOutFifo_(dof), 
  pEventOutFifo_(eof), 
  ID_(ID), 
  fl_(NULL), 
  samplePos_(0), 
  datasrc_(0)
{
  
  pOutBuffer_ = pDataOutFifo_->request();
  
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
      
      memcpy(&(pOutBuffer_->buffer[12 + sizeof(sample_t)*samplePos_]), 
	     &y, sizeof(samplePos_)); 
      
      samplePos_++; 

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
  pOutBuffer_->buffer[0] = DATATYPE; 
  pOutBuffer_->buffer[1] = datasrc_; 
  short len = hostToNet((unsigned short)
			(sizeof(sample_t) * samplePos_ + 10)); 

  unsigned long long ts = pSystemTimer_->getTime(); 
  unsigned long long tsnet = hostToNet(ts); 

  memcpy(&(pOutBuffer_->buffer[2]), &tsnet, 8); 

  memcpy(&(pOutBuffer_->buffer[2]), &len, sizeof(short)); 
  
  
  pOutBuffer_->commit(); 
  
  pOutBuffer_ = pDataOutFifo_->request(); 
  

}

void RawSink::onEvent(const Event&)
{

}
  
