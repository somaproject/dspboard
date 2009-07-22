#include <filterlinks/delta.h>

namespace dspboard { 

Delta::Delta() :
  input(fastdelegate::MakeDelegate(this, &Delta::newSample)),
  buffer_(1), 
  output(&buffer_, this)
{

  output.samplerate = 0;  // FIXME need to compute from source

}

filterid_t Delta::getFilterID() {
  return 1; 
}


bool Delta::setFilterID(filterid_t) {
  return false; 
}

void Delta::newSample(sample_t data)
{
  buffer_.append(data); 
  output.newSample(data); 
  
}

Delta::~Delta()
{


}
}
