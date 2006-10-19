#ifndef FAKEDATASRC_H
#define FAKEDATASRC_H

#include <datasourcebase.h>
#include <samplebuffer.hpp> 
#include <event.h>

class FakeDataSrc : public DataSourceBase
{
public: 
  FakeDataSrc(); 
  void sampleProcess();
  bool readySample(); 
  int getChanNum(void); 
  SampleBuffer<sample_t> * getChannelBuffer(int i); 
  void onEvent(const Event &);
  SampleRingBuffer<sample_t> sampleBuffer_; 
}; 

#endif // FAKEDATASRC_H
