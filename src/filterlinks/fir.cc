#include <filterlinks/fir.h>
#include <filter.h>
#include <filterlinks/delta.h>

FIR::FIR(AvailableFIRs * afirs) :
  input(fastdelegate::MakeDelegate(this, &FIR::newSample)),
  buffer_(1), 
  output(&buffer_, this),
  afs(afirs)
{

  output.samplerate = 0;  // FIXME need to compute from source
  
}


void FIR::newSample(sample_t data)
{
  
  int32_t val = convolve(input.pSampleBuffer_->start(), 
			 input.pSampleBuffer_->length(), 
			 input.pSampleBuffer_->head(), 
			 filter_, FIRLENMAX); 
  
  
  // get the connected 
  buffer_.append(val); 
  output.newSample(val); 
  
}

FIR::~FIR()
{


}

bool FIR::setFilterID(filterid_t fid) {
  bool found = false; 
  int pos = 0; 
  for (int i = 0; i < AvailableFIRs::FILTERNUM; i++) {
    if (afs->filterset[i]) {
      if (afs->filterids[i] == fid) {
	found = true; 
	pos = i; 
	break;
      }
    }
  }
  if (!found) {
    return false; 
  } 
  filter_ = afs->filters[pos]; 
  filterLen_ = afs->filterlens[pos]; 
  filterID_ = fid; 
  return true; 
}

filterid_t FIR::getFilterID()
{
  return filterID_; 
}
