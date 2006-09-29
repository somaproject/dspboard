#include <boost/test/unit_test.hpp>
using boost::unit_test::test_suite;

#include <samplebuffer.hpp>
#include <filterlinks/delta.h>

/*

Things to test: 

*/


void insert_test(void)
{
  // create sample buffer

  const int N = 100; 
  SampleRingBuffer<sample_t> srb(N); 

  // append N and then read out
  Delta test((SampleBuffer<sample_t>*)&srb); 
  
  for (int i = 0; i < N; i++)
    {
      srb.append(i); 
      BOOST_CHECK_EQUAL(test.nextSample(), i ); 
    }

}

test_suite*
init_unit_test_suite( int argc, char* argv[] )
{
  
  test_suite* test= BOOST_TEST_SUITE( "Ring Buffer test" );
 
  test->add( BOOST_TEST_CASE( &insert_test ) ); 
  
  return test;
	     
}
