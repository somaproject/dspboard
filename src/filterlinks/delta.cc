#include <filterlinks/delta.h>

Delta::Delta() :
  input(fastdelegate::MakeDelegate(this, &Delta::newSample)),
  buffer_(1), 
  output(&buffer_)
{

  output.samplerate = 0;  // FIXME need to compute from source

}


void Delta::newSample(sample_t data)
{
  buffer_.append(data); 
  output.newSample(data); 
  
}

Delta::~Delta()
{


}
