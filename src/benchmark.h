#ifndef BENCHMARK_H
#define BENCHMARK_H

#include <hw/misc.h>
#include <types.h>

/*
  Generic data for manipulating a global set of benchmark data


*/ 

class Benchmark
{
  static const short NUMBENCH = 6; 
public:
  Benchmark(); 
  uint32_t read(short i); 
  uint32_t max(short i); 

  inline void start(short i )
  {
    start_[i] = cycles(); 
    
  }

  inline void stop(short i )
  {
    stop_[i] = cycles(); 
    duration_[i] = stop_[i] - start_[i]; 
    if(duration_[i] > max_[i]) {
      max_[i] = duration_[i];
    }
    
  }



private:
  uint32_t start_[NUMBENCH]; 
  uint32_t stop_[NUMBENCH]; 
  uint32_t duration_[NUMBENCH]; 
  uint32_t max_[NUMBENCH]; 

}; 



#endif // BENCHMARKH
