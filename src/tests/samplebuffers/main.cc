#include <boost/test/unit_test.hpp>
using boost::unit_test::test_suite;

#include <samplebuffer.hpp>
/*

Things to test: 
does zero() really zero? 
does append() behave as we want it to? 
what about []

*/


void insert_test(void)
{
  // create sample buffer

  const int N = 100; 
  SampleRingBuffer<sample_t> srb(N); 

  // append N and then read out
  
  for (int i = 0; i < N; i++)
    {
      srb.append(i); 
    }

  for (int i = 0; i < N; i++)
    {
      BOOST_CHECK_EQUAL(srb[i], N-i-1); 
    }
}

void wrap_test(void)
{
  // create sample buffer

  const int N = 100; 
  SampleRingBuffer<unsigned char> srb(N); 

  // append N and then read out
  
  for (int i = 0; i < 2*N; i++)
    {
      srb.append(i); 
    }

  for (int i = 0; i < N; i++)
    {
      BOOST_CHECK_EQUAL(srb[i], 2*N-i-1); 
    }
}

test_suite*
init_unit_test_suite( int argc, char* argv[] )
{
  
  test_suite* test= BOOST_TEST_SUITE( "Ring Buffer test" );
  
  test->add( BOOST_TEST_CASE( &insert_test ) ); 
  test->add( BOOST_TEST_CASE( &wrap_test ) ); 
  
  return test;
	     
}
