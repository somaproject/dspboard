#ifndef FILTERIO_H
#define FILTERIO_H

#include <samplebuffer.hpp>
#include <FastDelegate.h>

template<class T> 
class FilterLinkSink; 

template<class T> 
class FilterLinkSource
{
public:

  static const int MAXSINKS = 4; 
  FilterLinkSource(SampleBuffer<T> * psb) :
    pSampleBuffer_(psb)
  {
    for (char i = 0; i < MAXSINKS; i++) {
      connectedSinks_[i] = 0; 
    }

  }
  
  void connect(FilterLinkSink<T> & psink) {
    for (char i = 0; i < MAXSINKS; i++) {
      if (connectedSinks_[i] == 0) {
	connectedSinks_[i] = &psink; 
	psink.setBuffer(pSampleBuffer_); 
	break; 
      }
    }
    
  }

  SampleBuffer<T> * pSampleBuffer_; 
  
  void newSample(T sample) {
    for (char i = 0; i < MAXSINKS; i++) {
      if (connectedSinks_[i] != 0) {
	connectedSinks_[i]->newSample(sample); 
      }
    }
  }

private:
  FilterLinkSink<T> * connectedSinks_[MAXSINKS]; 


  

}; 


template<class T>
class FilterLinkSink
{
  typedef fastdelegate::FastDelegate1<T>  newSampleDelegate_t; 
public:
  FilterLinkSink(newSampleDelegate_t nsd) :
    newSampleDelegate_(nsd), 
    pSampleBuffer_(0)
  {
    
  }

  SampleBuffer<T> * pSampleBuffer_; 

  void setBuffer(SampleBuffer<T> * psb) {
    pSampleBuffer_ = psb; 
  }
  
  void newSample(T sample) {
    newSampleDelegate_(sample); 
  }
  
private:
  newSampleDelegate_t newSampleDelegate_; 
  
}; 


#endif // FILTERIO_H
