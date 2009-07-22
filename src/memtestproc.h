#ifndef DSPBOARD_MEMTESTPROC
#define DSPBOARD_MEMTESTPROC

#include <event.h>
#include <hw/eventtx.h>
#include <dsp.h>
#include <eventdispatch.h>
#include <systemtimer.h>


/*
  The entire purpose of this device, which sits on the event bus, 
  is to run on-device tests of our custom, optimized memtest routine. 

*/ 
namespace dspboard { 
class MemTestProc
{
  
public:
  static const char ECMD_MEMTEST_RUN = 0xFA; 
  static const char ECMD_MEMTEST_RESULTS = 0xFB; 
  
  MemTestProc(EventDispatch * ed, EventTX* etx, 
		unsigned char device); 

  void eventRunTest(dsp::Event_t * et); 
  void eventReadTest(dsp::Event_t * et); 

private:  
  short eventpos; 
  EventTX* petx; 
  char device_; 

  // benchmarking / performance
  static const short NUMTEST = 20; 
  uint32_t test_time_[NUMTEST]; 
  uint32_t test_results_[NUMTEST]; 
  
  enum TESTS {
    HELLO_TEST = 0x00, 
    SIMPLE_COPY_TEST = 0x01, 
    SIMPLE_COPY_32_TEST = 0x02, 
    MISALIGNED_COPY_32_TEST = 0x03, 
    REVERSE_COPY_32_TEST = 0x04, 
    REVERSE_COPY_32_TEST_ALIGNED = 0x05, 
    REVERSE_COPY_32_TEST_MISALIGNED = 0x06 

  }; 

  void run_hello_test(dsp::Event_t * et); 
  void run_simple_copy_test(dsp::Event_t * et); 
  void run_simple_copy_32_test(dsp::Event_t * et); 
  void run_misaligned_copy_32_test(dsp::Event_t * et); 
  void run_reverse_copy_32_test(dsp::Event_t * et); 
  void run_reverse_copy_32_test_aligned(dsp::Event_t * et); 
  void run_reverse_copy_32_test_misaligned(dsp::Event_t * et); 

  // memory regions for testing
  static const int BUFFER_A_SIZE = 256; 
  unsigned char buffer_a[BUFFER_A_SIZE] __attribute__ ((aligned (8)));
  unsigned char buffer_a2[BUFFER_A_SIZE] __attribute__ ((aligned (8)));

  static const int BUFFER_B_SIZE = 128; 
  uint32_t buffer_b[BUFFER_A_SIZE] __attribute__ ((aligned (8)));
  uint32_t buffer_b2[BUFFER_A_SIZE] __attribute__ ((aligned (8)));

  
};

}

#endif // MEMTESTPROC
