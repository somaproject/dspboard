#ifndef FILTERLINK_FIR_H
#define FILTERLINK_FIR_H

#include <filterlinkbase.h>
/*

What do we want here? 

do we want FIR<h>? 

Do we want FIR(argument)? 

*/
class FIR : public  FilterLink
{

 public: 
  FIR(SampleBuffer<sample_t> *, sample_t* h); 
  ~FIR(); 

  sample_t nextSample(void); 
  
 private: 
  const sample_t * ph_; 

}; 

#endif // FILTERLINK_FIR_H
