#include <boost/test/unit_test.hpp>
#include <callback.h>
#include <iostream>
#include <vector>

using boost::unit_test::test_suite;

int counter = 0 ; 

class A
{
public:
  A(int x) {
    privatex_ = x; 
  }
  void f();
private:
  int privatex_; 
};

void A::f()
{
  counter += privatex_; 
}

class B
{
public:

  B(int x) {
    privatex_ = x; 
  }

  void f();

private:
  int privatex_; 

};

void B::f()
{
  counter += 2*privatex_; 
}



void callback_test(void)
{

  std::vector<CallbackBase*> test(4); 
  
  A a(10), b(20), c(30); // first, create an object

  B d(40); 

  Callback < A > c1(a, &A::f ); // instantiate template 
  Callback < A > c2(b, &A::f ); // instantiate template 
  Callback < A > c3(c, &A::f ); // instantiate template 
  Callback < B > c4(d, &B::f ); // instantiate template 


  test[0] = &c1; 
  (*test[0])(); 
  BOOST_CHECK_EQUAL(10, counter); 


  test[1] = &c2; 
  (*test[1])(); 
  BOOST_CHECK_EQUAL(30, counter); 

  test[2] = &c3; 
  (*test[2])(); 
  BOOST_CHECK_EQUAL(60, counter); 

  test[3] = &c4; 
  (*test[3])(); 
  BOOST_CHECK_EQUAL(140, counter); 


}

test_suite*
init_unit_test_suite( int argc, char* argv[] )
{
  
  test_suite* test= BOOST_TEST_SUITE( "Callback test" );
  
  test->add( BOOST_TEST_CASE( &callback_test ) ); 

  return test;
	     
}
