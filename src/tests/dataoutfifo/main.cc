#include <boost/test/unit_test.hpp>
#include <iostream>
#include <vector>
#include <stdexcept>

#include <hw/dspdataout.h>
#include <dataout.h>


using boost::unit_test::test_suite;
using namespace std; 

void dataout_simpletest(void)
{
  // Test if we can write a single buffer

  DSPDataOut ddo; 
  
  DataOutFifo dof(&ddo); 
  
  DataOutBuffer * db1 = dof.request(); 
  
  for (int i = 0; i < 256; i++) {
    db1->buffer[i]  = i; 
  }
  
  db1->commit(); 
  
  dof.sendBuffer(); 
  for (int i = 0; i < 256; i++ ){ 
    BOOST_CHECK(ddo.outbuf[i] == (char)i); 
  }

}

void dataout_allbufs()
{
  // Here we request all buffers, and then fill and commit them in a different
  // order, and check to make sure we get out all of our data. 

  std::vector<DataOutBuffer*> buffers(BUFNUM); 

  DSPDataOut ddo; 
  
  DataOutFifo dof(&ddo); 
  

  for (int i = 0; i < BUFNUM; i++) {
    buffers[i] = dof.request(); 
  }

  // fill them with data
  for (int i = 0; i < BUFNUM; i++) {
    for (int j = 0; j < BUFSIZE; j++) {
      buffers[i]->buffer[j] = i; 
    }
  }
  
  // commit them in a strange order
  for (int i = BUFNUM; i > 0;  i--) {
    buffers[i-1]->commit(); 
  }
  
  // verify the output is in the correct order
  
  for (int i = BUFNUM; i > 0;  i--) {
    dof.sendBuffer(); 
    for (int j = 0; j < BUFSIZE; j++) {
      BOOST_CHECK(ddo.outbuf[j] == i-1); 
    }
    ddo.doneState = true; 
  }
    
}


void dataout_outofbufs()
{
  // reserve all the buffers and then try and acquire one

  DSPDataOut ddo; 
  
  DataOutFifo dof(&ddo); 
  

  for (int i = 0; i < BUFNUM; i++) {
    dof.request(); 
  }

  BOOST_CHECK_THROW( dof.request(), std::runtime_error ); 


}  

test_suite*
init_unit_test_suite( int argc, char* argv[] )
{
  
  test_suite* test= BOOST_TEST_SUITE( "DSP Data out test" );
  
  test->add( BOOST_TEST_CASE( &dataout_simpletest ), 0, 1 ); 
  test->add( BOOST_TEST_CASE( &dataout_allbufs ), 0, 1 ); 
  test->add( BOOST_TEST_CASE( &dataout_outofbufs ), 0, 1); 

  return test;
	     
}
