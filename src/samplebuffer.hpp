#ifndef SAMPLEBUFFER_H
#define SAMPLEBUFFER_H
#include <types.h>

typedef int32_t sample_t; 

template <class T>
class SampleBuffer
{
 public:
  virtual void zero(void) = 0; 
  virtual void append(T x) = 0; 
  virtual T operator[] (unsigned i) = 0; 
  virtual T * head() = 0; 
  virtual int length() = 0; 
  virtual T * start() = 0; 
  
} ; 


template <class T> 
class SampleRingBuffer : public SampleBuffer<T>
{
  
public: 
  SampleRingBuffer(int N) :
    N_(N) 
  {
    pBuffer_ = new T[N_]; 
    zero(); 
  }
  
  inline void zero(void) {
    
    for (int i = 0; i < N_; i++)
      pBuffer_[i] = 0; 
    
    tpos_ = 0; 
    
  }
  

  
  inline void append(T x) {
    tpos_ = (tpos_ -  1);
    if (tpos_ < 0) 
      tpos_ += N_; 
    
    pBuffer_[tpos_] = x; 
  }
  
  inline T operator[] (unsigned i) {
    return pBuffer_[( i + tpos_) % N_]; 
  }
  
  inline T * head() {
    return &(pBuffer_[tpos_]); 
  }
  
  inline T * start() {
    return pBuffer_; 
  }
  
  inline int length() {
    return N_; 
  }

private: 
  T * pBuffer_;
  int tpos_; 
  int N_; 

}; 



#endif // SAMPLEBUFFER_H
