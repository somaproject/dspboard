#include "dspcontrol.h"


namespace dspiolib {

  namespace ads =  codec::AcqDataSource; 
  namespace tspike = codec::TSpikeSink; 

  
  StateProxy::StateProxy(datasource_t dsrc, const sigc::slot<void, const EventTX_t & > & etgt) :
    dsrc_(dsrc), 
    src_(dsrc + 0x08),
    eventTX_(etgt), 
    acqdatasrc(*this), 
    tspikesink(*this), 
    wavesink(*this)
  {
    
  }

  void StateProxy::newEvent(const Event_t & event) {
    // FIXME: WARNING LINEAR TIME
    acqdatasrc.newEvent(event); 
    tspikesink.newEvent(event); 
    wavesink.newEvent(event); 
    
  }
  
  void StateProxy::setETXDest(EventTX_t &  etx)
  {
    etx.destaddr[src_] = true; 
    etx.event.src = src_; 
  }

  AcqDataSource::AcqDataSource(StateProxy & parent) :
    parent_(parent)
  {
    // initialize to sane values
    linkStatus_ = false; 
    mode_  = 0; 
    for (int i = 0; i < CHANCNT; i++) {
      gains_[i] = 0; 
      hpfens_[i] = false; 
    }
    chansel_ = 0; 
    std::cout << "parent dsrc = " << (int)parent_.dsrc_ << std::endl;
    std::cout << "AcqDataSource init mid0" << std::endl;

    // send queries
    EventTX_t etx = ads::queryLinkStatus(); 
    parent_.setETXDest(etx); 
    parent_.eventTX_(etx); 
    std::cout << "AcqDataSource init mid1" << std::endl;
    
    etx = ads::queryMode(); 
    parent_.setETXDest(etx); 
    parent_.eventTX_(etx); 

    for (int i = 0; i < CHANCNT; i++) {
      etx = ads::queryGain(i); 
      parent_.setETXDest(etx); 
      parent_.eventTX_(etx); 

      etx = ads::queryHPF(i); 
      parent_.setETXDest(etx); 
      parent_.eventTX_(etx); 
    }

    etx = ads::queryChanSel(); 
    parent_.setETXDest(etx); 
    parent_.eventTX_(etx); 
    std::cout << "AcqDataSource init done" << std::endl;
  
    
  }
  
  bool AcqDataSource::newEvent(const Event_t & event)
  {
    switch(event.cmd) {
    case codec::AcqDataSource::RESPBCAST :
      parseEvent(event); 
      return true; 
    default:
      return false; 
    }
       
  }
  
  void AcqDataSource::parseEvent(const Event_t & event) {
    
    ads::PARAMETERS p = ads::whichParam(event); 
    switch(p) {
    case ads::LINKSTATUS: 
      {
	bool linkstatus = ads::linkStatus(event); 
	if (linkStatus_ != linkstatus) {
	  linkStatus_ = linkstatus; 
	  linkStatusSignal_.emit(linkStatus_); 
	}
      }
      break;

    case ads::MODE:
      {
	int mode = ads::mode(event); 
	if (mode_ != mode) {
	  mode_ = mode; 
	  modeSignal_.emit(mode); 
	}
      }
      break; 
      
    case ads::CHANGAIN:
      {
	ads::changain_t gain = ads::changeGain(event); 
	if (gains_[gain.first] != gain.second) {
	  gains_[gain.first] = gain.second; 
	  gainSignal_.emit(gain.first, gain.second); 
	}
      }
      break; 

    case ads::CHANHPF:
      {
	ads::chanhpf_t hpf = ads::changeHPF(event); 
	if (hpfens_[hpf.first] != hpf.second) {
	  hpfens_[hpf.first] = hpf.second; 
	  hpfenSignal_.emit(hpf.first, hpf.second); 
	}
      }
      break; 

    case ads::CHANRANGEMIN:
      {
	ads::chanrange_t range = ads::chanRangeMin(event); 
	if (ranges_[range.first].first != range.second) {
	  ranges_[range.first].first = range.second; 
	  rangeSignal_.emit(range.first, ranges_[range.first]); 
	}
      }
      break; 

    case ads::CHANRANGEMAX:
      {
	ads::chanrange_t range = ads::chanRangeMax(event); 
	if (ranges_[range.first].second != range.second) {
	  ranges_[range.first].second = range.second; 
	  rangeSignal_.emit(range.first, ranges_[range.first]); 
	}
      }
      break; 

    default:
      // FIXME Add the rest here!!!
      break;
    }
  }

  bool AcqDataSource::getLinkStatus()
  {
    return linkStatus_; 
  }
  
  sigc::signal<void, bool> & AcqDataSource::linkStatus()
  {
    return linkStatusSignal_; 
  }
  
  int AcqDataSource::getMode()
  {
    return mode_; 
  }
  
  void AcqDataSource::setMode(int mode)
  {
    
    EventTX_t etx = ads::mode(mode); 
    parent_.setETXDest(etx); 
    parent_.eventTX_(etx); 

  }

  sigc::signal<void, int> & AcqDataSource::mode()
  {
    return modeSignal_; 
  }


  int AcqDataSource::getGain(int chan) {
    return gains_[chan]; 

  }
  
  void AcqDataSource::setGain(int chan, int gain) {
    ads::changain_t cg; 
    cg.first = chan; 
    cg.second = gain; 
    EventTX_t etx = ads::changeGain(cg); 
    parent_.setETXDest(etx); 
    parent_.eventTX_(etx); 
  }

  sigc::signal<void, int, int> & AcqDataSource::gain()
  {
    return gainSignal_; 

  }

  bool AcqDataSource::getHPFen(int chan)
  {
    return hpfens_[chan];
  }
  
  void AcqDataSource::setHPFen(int chan, bool val)
  {
    ads::chanhpf_t hpf; 
    hpf.first = chan; 
    hpf.second = val; 

    EventTX_t etx = ads::changeHPF(hpf); 
    parent_.setETXDest(etx); 
    parent_.eventTX_(etx); 

  }

  sigc::signal<void, int, bool> & AcqDataSource::hpfen()
  {
    return hpfenSignal_; 
  }

  TSpikeSink::TSpikeSink(StateProxy & sp) : 
    parent_(sp)
  {
    

  }
  
  int AcqDataSource::getChanSel()
  {
    return chansel_; 
  }

  void AcqDataSource::setChanSel(int chan)
  {
    EventTX_t etx = ads::chanSel(chan); 
    parent_.setETXDest(etx); 
    parent_.eventTX_(etx); 
  }

  sigc::signal<void, int> & AcqDataSource::chansel()
  {
    return chanselSignal_; 
  }
  

  range_t AcqDataSource::getRange(int chan) {
    return ranges_[chan]; 
  }
  
  sigc::signal<void, int, range_t> & AcqDataSource::range()
  {
    return rangeSignal_; 
  }

  bool TSpikeSink::newEvent(const Event_t & event)
  {
    switch(event.cmd) {
    case tspike::RESPBCAST :
      parseEvent(event); 
      return true; 
    default:
      return false; 
    }
       
  }

  void TSpikeSink::parseEvent(const Event_t & event)
  {

    tspike::PARAMETERS p = tspike::whichParam(event); 
    switch(p) {
    case tspike::THRESHOLD:
      {
	tspike::chanthold_t thold = tspike::changeThreshold(event); 
	if (tholds_[thold.first] != thold.second) {
	  tholds_[thold.first] = thold.second; 
	  tholdSignal_.emit(thold.first, thold.second); 
	}
      }
      break; 

    case tspike::FILTERID:
      {
	tspike::chanfiltid_t filtid = tspike::changeFilterID(event); 
	if (filterids_[filtid.first] != filtid.second) {
	  filterids_[filtid.first] = filtid.second; 
	  filterIDSignal_.emit(filtid.first, filtid.second); 
	}
      }
      break; 

    }
    
  }
  

  sigc::signal<void, int, int> & TSpikeSink::thold()
  {
    return tholdSignal_; 
  }

  void TSpikeSink::setThold(int chan, int thold)
  {
    tspike::chanthold_t ct; 
    ct.first = chan; 
    ct.second = thold; 
    EventTX_t etx = tspike::changeThreshold(ct); 
    parent_.setETXDest(etx); 
    parent_.eventTX_(etx); 

  }

  int TSpikeSink::getThold(int chan)
  {
    return tholds_[chan];
  }
  
  sigc::signal<void, int, filterid_t> & TSpikeSink::filterID()
  {
    return filterIDSignal_; 
  }

  void TSpikeSink::setFilterID(int chan, filterid_t filterID)
  {
    tspike::chanfiltid_t cfid; 
    cfid.first = chan; 
    cfid.second = filterID; 
    EventTX_t etx = tspike::changeFilterID(cfid); 
    parent_.setETXDest(etx); 
    parent_.eventTX_(etx); 

  }

  filterid_t TSpikeSink::getFilterID(int chan)
  {
    return filterids_[chan];

  }


  WaveSink::WaveSink(StateProxy & sp) :
    parent_(sp)
  {

  }

  bool WaveSink::newEvent(const Event_t & event)
  {

    switch(event.cmd) {
    case codec::WaveSink::RESPBCAST :
      parseEvent(event); 
      return true; 
    default:
      return false; 
    }
    
  }

  void WaveSink::parseEvent(const Event_t & event)
  {


  }
}
