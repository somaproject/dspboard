#include "memtestproc.h" 
#include <filter.h>
#include <hw/misc.h>
#include <hw/memory.h>

MemTestProc::MemTestProc(EventDispatch * ed, EventTX* etx, 
			     unsigned char device) : 
  eventpos(0), 
  petx(etx), 
  device_(device)
{
  
  ed->registerCallback(ECMD_MEMTEST_RUN, fastdelegate::MakeDelegate(this, 
							&MemTestProc::eventRunTest)); 
  
  ed->registerCallback(ECMD_MEMTEST_RESULTS, fastdelegate::MakeDelegate(this, 
							&MemTestProc::eventReadTest)); 
    

    
  for (int i = 0; i < NUMTEST; i++){
    test_time_[i] = 0; 
    test_results_[i] = 0;     
  }
  
}

void MemTestProc::eventRunTest(dsp::Event_t * et) {
  
  switch(et->data[0]) {
  case HELLO_TEST : 
    run_hello_test(et); 
    break; 
  case SIMPLE_COPY_TEST : 
    run_simple_copy_test(et); 
    break; 
  case SIMPLE_COPY_32_TEST : 
    run_simple_copy_32_test(et); 
    break; 
  case MISALIGNED_COPY_32_TEST : 
    run_misaligned_copy_32_test(et); 
    break; 
  case REVERSE_COPY_32_TEST : 
    run_reverse_copy_32_test(et); 
    break; 
  case REVERSE_COPY_32_TEST_ALIGNED : 
    run_reverse_copy_32_test_aligned(et); 
    break; 
  case REVERSE_COPY_32_TEST_MISALIGNED : 
    run_reverse_copy_32_test_misaligned(et); 
    break; 
  default: 
    break; 
  }
  
}

void MemTestProc::eventReadTest(dsp::Event_t * et) {
  dsp::EventTX_t etx ;
  etx.addr[0] = 0xF;  // FIXME Actually send to requester

  etx.event.cmd = ECMD_MEMTEST_RESULTS; 
  etx.event.src = device_;

  char chan = et->data[0]; 

  etx.event.data[1] = test_time_[chan] >> 16; 
  etx.event.data[2] = test_time_[chan] & 0xFFFF; 
  etx.event.data[3] = test_results_[chan] >> 16; 
  etx.event.data[4] = test_results_[chan] & 0xFFFF; 
  petx->newEvent(etx); 
  
}

void MemTestProc::run_hello_test(dsp::Event_t * et)
{
  test_results_[HELLO_TEST]++; 

}

void MemTestProc::run_simple_copy_test(dsp::Event_t * et)
{
  /*
    Simply copy a buffer of characters from src
    to destination
  */

  for(unsigned short i = 0; i < BUFFER_A_SIZE; i++) {
    buffer_a[i] = i; 
  }
  uint64_t t1 = cycles(); 
  memcpy(buffer_a2, buffer_a, BUFFER_A_SIZE);   
  uint64_t t2 = cycles(); 
  t2 = t2 - t1; 
  test_time_[SIMPLE_COPY_TEST] = t2; 
  
  bool success = true; 
  for(unsigned short i = 0; i < BUFFER_A_SIZE; i++) {
    if (buffer_a2[i] != i) {
      success = false; 
    }
  }
  if (success) {
    test_results_[SIMPLE_COPY_TEST]++;
  }
  
  
}


void MemTestProc::run_simple_copy_32_test(dsp::Event_t * et)
{
  /* 
     copy a buffer of 32-bit nums from src to destination,
     where both are 32-bit aligned
  */

  for(unsigned short i = 0; i < BUFFER_B_SIZE; i++) {
    buffer_b[i] = i * 0x1234;  
  }
  uint64_t t1 = cycles(); 
  memcpy(buffer_b2, buffer_b, BUFFER_B_SIZE * sizeof(uint32_t));   
  uint64_t t2 = cycles(); 
  t2 = t2 - t1; 
  test_time_[SIMPLE_COPY_32_TEST] = t2; 
  
  bool success = true; 
  for(unsigned short i = 0; i < BUFFER_B_SIZE; i++) {
    if (buffer_b2[i] != i * 0x1234) {
      success = false; 
    }
  }
  if (success) {
    test_results_[SIMPLE_COPY_32_TEST]++;
  }
  
  
}

void MemTestProc::run_misaligned_copy_32_test(dsp::Event_t * et)
{
  /*
    try a 32-bit copy, same as above, but with a slightly misaligned dest

    It doens't even need to be misaligned, simply casting the pointer
    away from an int screws us. 

  */
  for(unsigned short i = 0; i < BUFFER_B_SIZE; i++) {
    buffer_b[i] = i * 0x1234;  
  }
  uint64_t t1 = cycles(); 
  char * buffer_b2_off = (char*)buffer_b2; 
  //uint32_t * buffer_b2_off = buffer_b2; 
//   buffer_b2_off++; 
//   buffer_b2_off++; 
//   buffer_b2_off++; 
//   buffer_b2_off++; 
  memcpy((char*)buffer_b2, buffer_b, (BUFFER_B_SIZE - 1) * sizeof(uint32_t));   
  uint64_t t2 = cycles(); 
  t2 = t2 - t1; 
  test_time_[MISALIGNED_COPY_32_TEST] = t2; 
  
  bool success = true; 
  for(unsigned short i = 0; i < (BUFFER_B_SIZE-1); i++) {
    if (buffer_b2_off[i] != i * 0x1234) {
      success = false; 
    }
  }
  if (success) {
    test_results_[MISALIGNED_COPY_32_TEST]++;
  }
  
  
}

void MemTestProc::run_reverse_copy_32_test(dsp::Event_t * et)
{
  for(unsigned short i = 0; i < BUFFER_B_SIZE; i++) {
    buffer_b[i] = 0x11223344 + i;  
  }

  // try our own code
  uint64_t t1 = cycles(); 
  Memcopy::hton_int32array_unaligned((unsigned char *)buffer_b2, 
			   (int32_t*)buffer_b, BUFFER_B_SIZE); 
  uint64_t t2 = cycles(); 


  t2 = t2 - t1; 
  test_time_[REVERSE_COPY_32_TEST] = t2; 
  
  bool success = true; 
  for(unsigned short i = 0; i < BUFFER_B_SIZE; i++) {
    uint32_t x = 0x11223344; 
    x = x  + i; 

    if (buffer_b2[i] != Memcopy::hton_int32slow(x)) {
      success = false; 
    }
  }

  if (success) {
    test_results_[REVERSE_COPY_32_TEST]++;
  }
  
  
}

void MemTestProc::run_reverse_copy_32_test_aligned(dsp::Event_t * et)
{
  for(unsigned short i = 0; i < BUFFER_B_SIZE; i++) {
    buffer_b[i] = 0x11223344 + i;  
    buffer_b2[i] = 0x00000000; 
  }

  // try our own code
  uint64_t t1 = cycles(); 
  Memcopy::hton_int32array_aligned((int32_t*)buffer_b2, 
			   (int32_t*)buffer_b, BUFFER_B_SIZE); 
  uint64_t t2 = cycles(); 


  t2 = t2 - t1; 
  test_time_[REVERSE_COPY_32_TEST_ALIGNED] = t2; 
  
  bool success = true; 

  for(unsigned short i = 0; i < BUFFER_B_SIZE; i++) {
    uint32_t x = 0x11223344; 
    x = x  + i; 

    if (buffer_b2[i] != Memcopy::hton_int32slow(x)) {
      success = false; 
    }
  }

  if (success) {
    test_results_[REVERSE_COPY_32_TEST_ALIGNED]++;
  }
  
  
}


void MemTestProc::run_reverse_copy_32_test_misaligned(dsp::Event_t * et)
{
  /*
    use hton_int32_array and see if we correctly detect misalignment
    yet still get the right answers

  */
  unsigned char * b1; 
  unsigned char * b2; 
  b1 = (unsigned char*)&buffer_b[0]; 
  b2 = (unsigned char*)&buffer_b2[0]; 
  b1++;
  b2++; 
  uint32_t * b2int = (uint32_t*)b1; 
  uint32_t * b2bint = (uint32_t*)b2; 

  int N = BUFFER_B_SIZE - 1; 
  for(unsigned short i = 0; i < N; i++) {
    b1[i] = 0x11223344 + i;  
    b2[i] = 0; 
  }

  // try our own code
  uint64_t t1 = cycles(); 
  Memcopy::hton_int32array(b2, 
			   (int32_t*)buffer_b, BUFFER_B_SIZE); 
  uint64_t t2 = cycles(); 


  t2 = t2 - t1; 
  test_time_[REVERSE_COPY_32_TEST_MISALIGNED] = t2; 
  
//   bool success = true; 
//   for(unsigned short i = 0; i < BUFFER_B_SIZE; i++) {
//     uint32_t x = 0x11223344; 
//     x = x  + i; 

//     if (buffer_b2[i] != Memcopy::hton_int32slow(x)) {
//       success = false; 
//     }
//   }

//   if (success) {
//     test_results_[REVERSE_COPY_32_TEST_MISALIGNED]++;
//   }
  
  
}
