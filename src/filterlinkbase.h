#ifndef FILTERLINKBASE_H
#define FILTERLINKBASE_H

#include <samplebuffer.hpp> 
class FilterLink
{
 public:
  virtual sample_t nextSample(void) = 0; 
  
 protected:
  SampleBuffer<sample_t> * sampBuf_; 

}; 

#endif //FILTERLINKBASE_H

