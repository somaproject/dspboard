#ifndef DSP_IOLIB_EVENTCODEC_H
#define DSP_IOLIB_EVENTCODEC_H

/*
  collection of pure functions and structs to facilliate
  event construction and destruction. 
  

*/
#include <somanetwork/event.h>
#include <somanetwork/eventtx.h>
#include <somanetwork/network.h>

namespace dspiolib {
  namespace codec { 
    namespace AcqDataSource
    {
      using namespace somanetwork; 
      typedef std::pair<int, int> changain_t; 
      typedef std::pair<int, bool> chanhpf_t; 
      typedef std::pair<int, int32_t> chanrange_t; 
      
      EventTX_t queryLinkStatus(); 
      bool linkStatus(const Event_t & ); 
      
      EventTX_t changeGain(changain_t); 
      changain_t changeGain(const Event_t & ); 
      EventTX_t queryGain(int chan); 
      

      EventTX_t changeHPF(chanhpf_t); 
      chanhpf_t changeHPF(const Event_t & ) ; 
      EventTX_t queryHPF(int chan); 
      
      EventTX_t chanSel(int chan); 
      int chanSel(const Event_t & ); 
      EventTX_t queryChanSel(); 
      

      chanrange_t chanRangeMin(const Event_t & ); 
      EventTX_t queryChanRangeMin(int chan); 
      
      chanrange_t chanRangeMax(const Event_t & ); 
      EventTX_t queryChanRangeMax(int chan); 
      
      EventTX_t mode(int mode); 
      int mode(const Event_t & ); 
      EventTX_t queryMode(); 
      
      std::list<eventcmd_t> cmdsToReceive(); 
      
      enum CMDS {
	QUERY =0x40,
	SET = 0x41,
	RESPBCAST = 0x42
      }; 
      
      enum PARAMETERS {
	LINKSTATUS = 0, 
	MODE = 1, 
	CHANGAIN = 2, 
	CHANHPF = 3,
	CHANSEL = 4, 
	CHANRANGEMIN = 5, 
	CHANRANGEMAX = 6
      };
      PARAMETERS whichParam(const Event_t &); 
      
    }
    
    namespace TSpikeSink
    {
      using namespace somanetwork; 

      typedef std::pair<int, int> chanthold_t; 
      typedef std::pair<int, uint32_t> chanfiltid_t; 
      
      EventTX_t changeThreshold(chanthold_t); 
      chanthold_t changeThreshold(const Event_t & ); 
      EventTX_t queryThreshold(int chan); 
      
      EventTX_t changeFilterID(chanfiltid_t); 
      chanfiltid_t changeFilterID(const Event_t & ); 
      EventTX_t queryFilterID(int chan); 
      

      enum CMDS {
	QUERY = 0x43, 
	SET = 0x44, 
	RESPBCAST = 0x45, 
      }; 
      
      enum PARAMETERS { 
	THRESHOLD = 1,
	FILTERID = 2
      }; 
      
      std::list<eventcmd_t> cmdsToReceive(); 
      
      PARAMETERS whichParam(const Event_t &); 
    }
    
    namespace WaveSink
    {
      using namespace somanetwork; 
      enum CMDS { 
	QUERY = 0x46,  
	SET = 0x47, 
	RESPBCAST = 0x48, 
      }; 
      
      enum PARAMETERS { 
	SAMPRATENUM = 1, 
	SAMPRATEDEN = 2, 
	FILTERID = 3
      }; 
      
      std::list<eventcmd_t> cmdsToReceive(); 
      
    }
    
    namespace RawSink
    {
      // no control?
      
    }
        
  }
}

#endif // DSP_IOLIB_EVENTCODEC_H
