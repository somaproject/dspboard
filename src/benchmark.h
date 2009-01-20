#ifndef BENCHMARK_H
#define BENCHMARK_H

#include <hw/misc.h>
#include <types.h>
#include <filter.h>
#include <hw/memory.h>
#include <dsp.h>


class Benchmark {
  static  const int BENCHMARK_NUM = 6; 
  
  static uint32_t counters_start[BENCHMARK_NUM]; 
  static uint32_t counters_stop[BENCHMARK_NUM]; 
  static uint32_t counters_recent[BENCHMARK_NUM]; 
  static uint32_t counters_max[BENCHMARK_NUM]; 
  
public:
  Benchmark(); 

  void start(char i); 
  void stop(char i); 
  uint32_t recent(char i); 
  uint32_t max(char i); 
  
}; 

#endif
