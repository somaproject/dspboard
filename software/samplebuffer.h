#ifndef SAMPLEBUFFER_H
#define SAMPLEBUFFER_H

#include <iostream>

template <class T, int N> 
class SampleBuffer
{
 public: 
  SampleBuffer() {
    zero(); 
  }

  void zero(void) {

    for (int i = 0; i < N; i++)
      _buffer[i] = 0; 
    
    _tpos = 0; 

  }

  void append(T x) {
    _tpos = (_tpos -  1);
    if (_tpos < 0) 
      _tpos += N; 

    std::cout << _tpos << std::endl; 

    _buffer[_tpos] = x; 
  }

  T& operator[] (unsigned i) {
    return _buffer[( i + _tpos) % N]; 
  }

  T * head(); 

 private: 
  T _buffer[N];
  int _hpos, _tpos; 
  int _N; 


}; 



#endif // SAMPLEBUFFER_H
