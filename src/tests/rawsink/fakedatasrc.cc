#include <datasourcebase.h>
#include "fakedatasrc.h"

FakeDataSrc::FakeDataSrc() :
  sampleBuffer_(200)
{
}

void FakeDataSrc::sampleProcess()
{
  
}

bool FakeDataSrc::readySample()
{
  return true; 
} 

int FakeDataSrc::getChanNum()
{
  return 1; 
} 

SampleBuffer<sample_t> * FakeDataSrc::getChannelBuffer(int i)
{
  return &sampleBuffer_; 
  
}

void FakeDataSrc::onEvent(const Event &)
{
  
}
