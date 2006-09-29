#ifndef FILTERLINK_DELTA_H
#define FILTERLINK_DELTA_H

#include <filterlinkbase.h>

class Delta : public  FilterLink
{

 public: 
  Delta(SampleBuffer<sample_t> *); 
  ~Delta(); 

  sample_t nextSample(void); 
  
 private: 

}; 

#endif // FILTERLINK_DELTA_H
