#ifndef DSPBOARD_FILTERIO_H
#define DSPBOARD_FILTERIO_H

#include <samplebuffer.hpp>
#include <types.h>
#include <FastDelegate.h>

namespace dspboard { 
typedef uint32_t filterid_t; 

class FilterLink
{
public:
  virtual filterid_t getFilterID() = 0; 
  virtual bool setFilterID(filterid_t) = 0; // returns true if set was successful


}; 

template<class T> 
class FilterLinkSink; 

template<class T> 
class FilterLinkSource
{
public:

  static const int MAXSINKS = 4; 
  FilterLinkSource(SampleBuffer<T> * psb, FilterLink * fl) :
    pSampleBuffer_(psb), 
    pFilterLink_(fl)
  {
    for (char i = 0; i < MAXSINKS; i++) {
      connectedSinks_[i] = 0; 
      isConnected_[i] = false; 
    }

  }
  uint32_t samplerate; 
  uint32_t id; 

  void connect(FilterLinkSink<T> & psink) {
    for (char i = 0; i < MAXSINKS; i++) {
      if (! isConnected_[i]) {
	connectedSinks_[i] = &psink; 
	psink.setSource(this, pSampleBuffer_);
	isConnected_[i] = true; 
	break; 
      }
    }
  }

  SampleBuffer<T> * pSampleBuffer_; 
  FilterLink * pFilterLink_; 

  void inline newSample(T sample) {
    for (char i = 0; i < MAXSINKS; i++) {
      if (isConnected_[i]) {
	connectedSinks_[i]->newSample(sample); 
      }
    }
  }

private:
  FilterLinkSink<T> * connectedSinks_[MAXSINKS]; 
  bool isConnected_[MAXSINKS]; 
  

}; 


template<class T>
class FilterLinkSink
{
  typedef fastdelegate::FastDelegate1<T>  newSampleDelegate_t; 
public:
  FilterLinkSink(newSampleDelegate_t nsd) :
    newSampleDelegate_(nsd), 
    pSampleBuffer_(0), 
    pSource_(0)
  {
    
  }
  filterid_t getFilterID() {
    if (pSource_) {
      return pSource_->pFilterLink_->getFilterID(); 
    } else { 
      return 0;
    }

  }

  bool setFilterID(filterid_t fid) {
    if (pSource_) {
      return pSource_->pFilterLink_->setFilterID(fid); 
    } else {
      return false; 
    }
  }
  SampleBuffer<T> * pSampleBuffer_; 
  FilterLinkSource<T> * pSource_; 

  void setSource(FilterLinkSource<T> * psrc, SampleBuffer<T> * psb) {
    pSampleBuffer_ = psb; 
    pSource_ = psrc; 
  }
  
  void inline newSample(T sample) {
    newSampleDelegate_(sample); 
  }
  
private:
  newSampleDelegate_t newSampleDelegate_; 
  
}; 

}
#endif // FILTERIO_H
