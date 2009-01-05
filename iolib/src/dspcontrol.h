#ifndef DSP_IOLIB_CONTROL
#define DSP_IOLIB_CONTROL

#include <sigc++/sigc++.h>
#include <somanetwork/network.h>
#include "eventcodec.h"

/*
  caching of DSPboard state, event parsing and signal dispatch
  goal: 
     events in, state changes and signals out
     
  How do we know which events to deliver to the state proxy? 
  At the moment we're just going to give it all of them from its source
  
  FIXME:: Fix all-event passing someday so we don't do extra work. 

*/ 


namespace dspiolib {

  class StateProxy; 
  typedef std::pair<uint32_t, uint32_t> samprate_t;
  typedef uint32_t filterid_t; 
      typedef std::pair<int32_t, int32_t> range_t;

  // basically a proxy for remote state
    class AcqDataSource
    {
    public:
      
      sigc::signal<void, bool> & linkStatus(); 
      bool getLinkStatus(); 

      sigc::signal<void, int> & mode(); 
      int getMode(); 
      void setMode(int); 

      sigc::signal<void, int, int> & gain(); 
      void setGain(int chan, int gain); 
      int getGain(int chan); 

      sigc::signal<void, int, bool> & hpfen(); 
      bool getHPFen(int chan); 
      void setHPFen(int chan, bool val); 

      sigc::signal<void, int, range_t> & range(); 
      range_t getRange(int chan); 
      // there is no setter for range

      sigc::signal<void, int> & chansel(); 
      int getChanSel(); 
      void setChanSel(int); 

      bool newEvent(const Event_t & );

    private:
      AcqDataSource(StateProxy & parent); 
      
      StateProxy & parent_; 

      static const int CHANCNT = 5; 
      sigc::signal<void, bool> linkStatusSignal_; 
      sigc::signal<void, int> modeSignal_; 
      sigc::signal<void, int, int> gainSignal_; 
      sigc::signal<void, int, bool> hpfenSignal_; 
      sigc::signal<void, int>  chanselSignal_;
      sigc::signal<void, int, range_t> rangeSignal_; 
      
      bool linkStatus_; 
      int mode_; 
      int gains_[CHANCNT]; 
      bool hpfens_[CHANCNT]; 
      range_t ranges_[CHANCNT]; 
      int chansel_; 
      
      friend class StateProxy; 
      void parseEvent(const Event_t & event); 

    }; 
    
    class TSpikeSink
    {
    public:
      static const int CHANN = 4; 

      sigc::signal<void, int, int> & thold(); 
      void setThold(int chan, int thold); 
      int getThold(int chan); 

      sigc::signal<void, int, filterid_t> & filterID(); 
      void setFilterID(int chan, filterid_t filterID); 
      filterid_t getFilterID(int chan); 

    private:
      TSpikeSink(StateProxy & ); 
      
      friend class StateProxy; 
      bool newEvent(const Event_t & );
      StateProxy & parent_;
      int32_t thold_[CHANN]; 
      filterid_t filterid_[CHANN]; 
      void parseEvent(const Event_t & event); 
      
    }; 
    
    class WaveSink
    {
    public:
      sigc::signal<void, filterid_t> & filterID(); 
      void setFilterID(filterid_t filterID); 
      filterid_t getFilterID(); 
      
      sigc::signal<void, samprate_t > & sampratenum(); 
      void setSampRateNum(int chan, samprate_t); 
      samprate_t getSampRateNum(); 

    private:
      WaveSink(StateProxy & ); 
      friend class StateProxy; 
      bool newEvent(const Event_t & );
      StateProxy & parent_; 
      
      samprate_t samprate_; 
      filterid_t filterid_; 
      void parseEvent(const Event_t & event); 

    }; 
    
    
  class StateProxy {
  public:
    StateProxy(datasource_t dsrc, const sigc::slot<void, const EventTX_t &> & etgt); 
    
    void newEvent(const Event_t & event); 
    
    datasource_t dsrc_;
    eventsource_t src_; 

    const sigc::slot<void, const EventTX_t & > & eventTX_;
    
    AcqDataSource acqdatasrc; 
    TSpikeSink tspikesink; 
    WaveSink wavesink; 


    void setETXDest(EventTX_t &  etx); 

  private:

  }; 



}


#endif 
