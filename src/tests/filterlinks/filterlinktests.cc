#include <boost/test/unit_test.hpp>

#include <boost/test/auto_unit_test.hpp>
#include <arpa/inet.h>

#include <filterio.h>
#include <systemtimer.h>
#include <fakesource.h>
#include <sinks/rawsink.h>
#include <hostdataout.h>


BOOST_AUTO_TEST_SUITE(filterlinks_test); 

BOOST_AUTO_TEST_CASE(fakesource_rawsink_test)
{
  SystemTimer timer; 
  timer.setTime(0); 
  
  FakeSource fs(&timer); 
  HostDataOut dataout; 

  const char SRC =  10; 
  
  RawSink rawsink(&timer, &dataout, SRC); 

  fs.source.connect(rawsink.sink); 
  // now we run a loop of 12800 timestamps, which should give us 
  // 128 samples, and trigger the TX

  for (int i  = 1; i < 1290; i++) {
    timer.setTime(i); 
  }
  BOOST_CHECK_EQUAL(dataout.dataCount_,  1); 
  // now the painstaking process of checking the buffer
  int LEN = 128 * 4 + 2; 
  BOOST_CHECK_EQUAL(dataout.mostrecentbuffer[0], LEN >> 8); 
  BOOST_CHECK_EQUAL(dataout.mostrecentbuffer[1], LEN & 0xFF ); 
  
  // check SRC and TYP
  const char TYP = 2; 
  BOOST_CHECK_EQUAL(dataout.mostrecentbuffer[2], TYP); 
  BOOST_CHECK_EQUAL(dataout.mostrecentbuffer[3], SRC); 
  
  // data check
  for (int i = 0; i < RawData_t::BUFSIZE; i++) {
    int32_t hostx, netx = 0 ; 
    memcpy(&netx, &(dataout.mostrecentbuffer[i*4 + 4]), 4); 
    hostx = ntohl(netx); 

    BOOST_CHECK_EQUAL(hostx, i); 
  }
  

}


BOOST_AUTO_TEST_SUITE_END(); 

