#include <boost/test/unit_test.hpp>

#include <boost/test/auto_unit_test.hpp>

#include <filterio.h>


BOOST_AUTO_TEST_SUITE(filterio_test); 

using namespace dspboard; 

class SourceObject  : FilterLink {
public:
  SampleRingBuffer<int> bufA_; 
  SampleRingBuffer<int> bufB_; 
  SampleRingBuffer<int> bufC_; 

  FilterLinkSource<int> sourceA; 
  FilterLinkSource<int> sourceB;
  FilterLinkSource<int> sourceC; 
  filterid_t getFilterID() {
    return 117;
  }

  bool setFilterID(filterid_t) {
    return true; 
  }

  SourceObject() :
    bufA_(100), 
    bufB_(100), 
    bufC_(100), 
    sourceA(&bufA_, this), 
    sourceB(&bufB_, this), 
    sourceC(&bufC_, this)
  {


  }
  
  
  void sendSample(int x) {
    sourceA.newSample(x); 
    sourceB.newSample(x); 
    sourceC.newSample(x); 
  }

}; 

class SinkObject {
public:
  SinkObject() :
    sinkX(fastdelegate::MakeDelegate(this, &SinkObject::processX)), 
    sinkY(fastdelegate::MakeDelegate(this, &SinkObject::processY))
  {
    
  }
  FilterLinkSink<int> sinkX; 
  FilterLinkSink<int> sinkY; 
  
  int lastX_; 
  int lastY_; 
  void processY(int y) {
    lastY_ = y; 
  }

  void processX(int x) {
    lastX_ = x; 
  }

};

BOOST_AUTO_TEST_CASE(one_to_one_test)
{
  SourceObject source; 
  SinkObject sink; 
  source.sourceA.connect(sink.sinkX); 
  source.sendSample(0x12345678); 
  BOOST_CHECK_EQUAL(sink.lastX_, 0x12345678); 
  
}


BOOST_AUTO_TEST_CASE(one_to_many_test)
{
  SourceObject source; 
  SinkObject sink1, sink2; 
  source.sourceA.connect(sink1.sinkX); 
  source.sourceA.connect(sink2.sinkY); 
  source.sendSample(0x12345678); 
  BOOST_CHECK_EQUAL(sink1.lastX_, 0x12345678); 
  BOOST_CHECK_EQUAL(sink2.lastY_, 0x12345678); 
  
  source.sendSample(0x1122); 
  BOOST_CHECK_EQUAL(sink1.lastX_, 0x1122); 
  BOOST_CHECK_EQUAL(sink2.lastY_, 0x1122); 
  
}




BOOST_AUTO_TEST_SUITE_END(); 

