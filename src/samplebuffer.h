#ifndef SAMPLEBUFFER_H
#define SAMPLEBUFFER_H

#include <iostream>

typedef int32_t sample_t; 

template <class T>
class SampleBuffer
{
 public:
  virtual void zero(void) = 0; 
  virtual void append(T x) = 0; 
  virtual T operator[] (unsigned i) = 0; 
  virtual T * head() = 0; 
  virtual int length(); 
  virtual T * start(); 

} ; 


template <class T, int N=100> 
class SampleRingBuffer : public SampleBuffer<T>
  {
    
    public: 
    SampleRingBuffer() {
      zero(); 
  }

  void zero(void) {

    for (int i = 0; i < N; i++)
      buffer_[i] = 0; 
    
    tpos_ = 0; 

  }

  void append(T x) {
    tpos_ = (tpos_ -  1);
    if (tpos_ < 0) 
      tpos_ += N; 

    std::cout << tpos_ << std::endl; 

    buffer_[tpos_] = x; 
  }

T operator[] (unsigned i) {
    return buffer_[( i + tpos_) % N]; 
  }

T * head() {
}

 private: 
  T buffer_[N];
  int hpos_, tpos_; 
  int N_; 


}; 



#endif // SAMPLEBUFFER_H
