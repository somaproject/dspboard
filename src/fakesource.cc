#include "fakesource.h"

FakeSource::FakeSource(SystemTimer *pst) :
  pSystemTimer_(pst), 
  buffer_(BUFSIZE), 
  source(&buffer_, this), 
  val_(0)
{
  pst->connect(fastdelegate::MakeDelegate(this, &FakeSource::updateTime)); 
  
}

void FakeSource::updateTime(somatime_t t) 
{
  // if time changes by more than x, emit a sample
  if (t % 10 == 0) {
    buffer_.append(val_); 
    source.newSample(val_); 
    val_++; 
  }

}
