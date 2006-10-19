#include <boost/test/unit_test.hpp>
#include <iostream>
#include <vector>
#include "fakedatasrc.h"

#include <sinks/rawsink.h>
#include <hw/dspdataout.h>
#include <dataout.h>

#include <arpa/inet.h>


using boost::unit_test::test_suite;
using namespace std; 

void rawsink_simpletest(void)
{
  // we simply attempt to instantiate all of the objects, and then 
  // try reading out a sample buffer. 

  SystemTimer st; 
  FakeDataSrc fds; 
  FilterLinkManager flm(&fds); 
  
  DSPDataOut ddo; 
  DataOutFifo dof (&ddo); 
  
  EventOutFifo eof; 
  fds.sampleBuffer_.append(1); 

  RawSink rs(0, &flm, &st, &dof, &eof); 
  rs.newFilterLink(0, 0); 

  // this should totally generate a packet!
  for (int i = 0; i < 128; i++) {
    rs.sampleProcess(); 
  }
  

  dof.sendBuffer(); 
  
  for (int i = 0; i < 128; i++){
    BOOST_CHECK(ddo.outbuf[12+i*4+3] == 1); 
  }

}

unsigned char extractByte(unsigned long long x, int pos)
{
  // return the ith byte, where 0 == MSBs
  return (x >> (8*pos) ) & 0xFF; 

}
void rawsink_packettest(void)
{
  // we generate a bunch of packets and check their contents

  SystemTimer st; 
  FakeDataSrc fds; 
  FilterLinkManager flm(&fds); 
  
  DSPDataOut ddo; 
  DataOutFifo dof (&ddo); 
  
  EventOutFifo eof;
  
  RawSink rs(0, &flm, &st, &dof, &eof); 
  rs.newFilterLink(0, 0); 
  

  unsigned long long time = 1095816;   
  for (int pkt = 0; pkt < 10; pkt++) 
    {
      time = time << 1; 
      st.setTime(time); 
      
      // add values:
      
      
      // this should totally generate a packet!
      for (int i = 0; i < 128; i++){ 
	fds.sampleBuffer_.append(i * pkt); 
	rs.sampleProcess(); 
      }
      
      
      dof.sendBuffer(); 

      // validate entire buffer
      BOOST_CHECK_EQUAL(ddo.outbuf[0],  0x03); //TYPE
      BOOST_CHECK_EQUAL(ddo.outbuf[1], 0x00);  //SRC
      
      // timestamp
      for (int i = 0; i < 6; i++){
	BOOST_CHECK_EQUAL((unsigned char) ddo.outbuf[i+4], 
			  (unsigned char) extractByte(time, 5-i)  ); 
      }
      
      // src
      // type 
      // 
      for (int i = 0; i < 128; i++){
	//cout << hex << (int)ddo.outbuf[12+i*sizeof(sample_t)+3] << endl; 
	BOOST_CHECK_EQUAL((unsigned char) ddo.outbuf[12+i*4+3],
			  (i*pkt & 0xFF) ) ; 
	BOOST_CHECK_EQUAL((unsigned char) ddo.outbuf[12+i*4+2], 
			  ((i*pkt >> 8)& 0xFF) ) ; 

      }

      ddo.doneState = true; 
      
    }      
}


test_suite*
init_unit_test_suite( int argc, char* argv[] )
{
  
  test_suite* test= BOOST_TEST_SUITE( "rawsink test" );
  
  
  test->add( BOOST_TEST_CASE( &rawsink_simpletest)); 
  test->add( BOOST_TEST_CASE( &rawsink_packettest) );  
  return test;
	     
}
