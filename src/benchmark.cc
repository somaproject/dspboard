#include "benchmark.h"


Benchmark::Benchmark()
{
  for(char i = 0; i < NUMBENCH; i++) {
    start_[i] = 0; 
    stop_[i] = 0; 
    duration_[i] = 0; 
    max_[i] = 0; 
    
  }

}

uint32_t Benchmark::read(short i) {
  return duration_[i]; 
}

uint32_t Benchmark::max(short i) {
  return max_[i];
}
