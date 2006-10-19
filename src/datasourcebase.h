#ifndef DATASRC_H
#define DATASRC_H

#include <samplebuffer.hpp>

class DataSourceBase
{
 public: 
  virtual void sampleProcess() = 0; 
  virtual int getChanNum(void) = 0; 
  virtual SampleBuffer<sample_t> * getChannelBuffer(int i) = 0; 
  //virtual void onEvent(const Event &) = 0; 

}; 

#endif // DATASRC_H

