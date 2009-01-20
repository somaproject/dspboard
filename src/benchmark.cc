#include "benchmark.h"
#include <hw/memory.h>
#include <hw/misc.h>

uint32_t Benchmark::counters_start[BENCHMARK_NUM] = {0, 0, 0, 0, 0, 0}; 
uint32_t Benchmark::counters_stop[BENCHMARK_NUM] = {0, 0, 0, 0, 0, 0}; 
uint32_t Benchmark::counters_max[BENCHMARK_NUM] = {0, 0, 0, 0, 0, 0}; 
uint32_t Benchmark::counters_recent[BENCHMARK_NUM] = {0, 0, 0, 0, 0, 0}; 

Benchmark::Benchmark()
{
  
}

void Benchmark::start(char i) {

  counters_start[i] = cycles(); 
}

void Benchmark::stop(char i)
{

  counters_stop[i] = cycles(); 
  uint32_t delta = counters_stop[i] - counters_start[i]; 
  counters_recent[i] = delta; 
  if (delta > counters_max[i]) {
    counters_max[i] = delta; 
  }
  
}

uint32_t Benchmark::recent(char i){
  return counters_recent[i];
}

uint32_t Benchmark::max(char i)
{
  return counters_max[i];
}
