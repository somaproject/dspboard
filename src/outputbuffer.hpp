#ifndef OUTPUTBUFFER_H
#define OUTPUTBUFFER_H

#include <iostream>
#include <samplebuffer.hpp>

template <class T>
class OutputBuffer
{
 public:
  virtual void zero(void) = 0; 
  virtual void append(T x) = 0; 
  virtual int size() = 0; 
  virtual void linearcopy(int start, int stop, char * dest) =0;

  
} ; 


template <class T> 
class OutputRingBuffer : public OutputBuffer<T>
{
  
public: 

  OutputRingBuffer(int N) :
    N_(N) 
  {
    pBuffer_ = new T[N_]; 
    zero(); 
  }
  
  void zero(void) {
    
    for (int i = 0; i < N_; i++)
      pBuffer_[i] = 0; 
    
    tpos_ = N_ -1; 
    
  }
  
  void linearcopy(int start, int stop, char * dest)
  {
    /*
      copy starting at startpos and going forward. 
      so if Start is 30, we copy from the 30th most-recent sample
      up to the stop-th most recent. 

      linearcopy(31, 0, ) will copy 32 samples. 

      We start with the oldest samples such that the linear
      buffer increases positively in time. 
      
    */
    
    // tpos is the address of the most-recently-inserted 
    // sample. 
    int cstart = (tpos_ - start);
    if (cstart < 0)
      cstart += N_-1 + 1; 

    int cstop = (tpos_ - stop); 
    if (cstop < 0)
      cstop += N_; 

    if (cstart <= cstop) {
      memcpy(dest, &pBuffer_[cstart], (cstop - cstart + 1) * sizeof(T));
    } else {

      memcpy(dest, &pBuffer_[cstart], (N_ - cstart) * sizeof(T));
      memcpy(dest + (N_ - cstart)*sizeof(T),
	     &pBuffer_[0], (cstop + 1) * sizeof(T)) ; 
      
    }

  }
  
  void append(T x) {
    tpos_ = (tpos_ +  1);
    if (tpos_ == N_) 
      tpos_ = 0; 

    pBuffer_[tpos_] = x; 
  }
  
  int size() {
    return N_; 
  }

private: 
  T * pBuffer_;
  int tpos_; 
  int N_; 

}; 



#endif // OUTPUTBUFFER_H
