#include <somadspio/eventcodec.h>


namespace dspiolib
{ 
namespace codec
{
namespace AcqDataSource
{
  
EventTX_t queryLinkStatus()
{
  // does not set destination
  EventTX_t etx;
  etx.event.cmd = QUERY; 
  etx.event.data[0] = LINKSTATUS; 
  return etx; 
}


bool linkStatus(const Event_t & event)
{
  // Parse the inbound linkstatus event, returning up or down
  if(event.data[1] & 0x01 == 1) {
    return true; 
  } else {
    return false; 
  }

}

EventTX_t changeGain(changain_t cg)
{
  EventTX_t etx;
  etx.event.cmd = SET;
  etx.event.data[0] = CHANGAIN;
  etx.event.data[1] = 0x01 << cg.first; 
  etx.event.data[2] = (cg.second >> 16) & 0xFFFF; 
  etx.event.data[3] = cg.second & 0xFFFF; 
  return etx; 

}


changain_t changeGain(const Event_t & event)
{
  changain_t cg; 
  cg.first = event.data[1]; 
  uint32_t gain = 0; 
  gain = event.data[2]; 
  gain = (gain << 16) | event.data[3]; 
  cg.second = gain; 

  return cg; 

}

EventTX_t queryGain(int chan)
{
  EventTX_t etx;
  etx.event.cmd = QUERY;
  etx.event.data[0] = CHANGAIN;
  etx.event.data[1] = 0x01 << chan; 

  return etx; 
}


EventTX_t changeHPF(chanhpf_t ch)
{
  EventTX_t etx;
  etx.event.cmd = SET;
  etx.event.data[0] = CHANHPF;
  etx.event.data[1] = 0x01 << ch.first; 
  etx.event.data[2] = ch.second; 
  return etx; 

}

chanhpf_t changeHPF(const Event_t & event)
{
  chanhpf_t ch; 
  ch.first = event.data[1]; 
  ch.second = event.data[2]; 
  return ch; 
}

EventTX_t queryHPF( int chan)
{
  EventTX_t etx;
  etx.event.cmd = QUERY;
  etx.event.data[0] = CHANHPF;
  etx.event.data[1] = 0x01 <<  chan; 
  return etx; 
  

}

EventTX_t chanSel(int chan)
{
  EventTX_t etx;
  etx.event.cmd = SET;
  etx.event.data[0] = CHANSEL;
  etx.event.data[1] = chan; 
  return etx; 
  
}

int chanSel(const Event_t & event )
{
  std::cout << "EventCodec chansel event " << event.data[1] << std::endl;
  return event.data[1]; 
}


EventTX_t queryChanSel()
{

  EventTX_t etx;
  etx.event.cmd = QUERY;
  etx.event.data[0] = CHANSEL;

  return etx; 
}

EventTX_t mode(int mode)
{
  EventTX_t etx;
  etx.event.cmd = SET;
  etx.event.data[0] = MODE;
  etx.event.data[1] = mode; 
  return etx; 
  
}


int mode(const Event_t & event )
{
  return event.data[1]; 
}

EventTX_t queryMode( )
{
  EventTX_t etx;
  etx.event.cmd = QUERY;
  etx.event.data[0] = MODE;
  return etx; 


}


EventTX_t queryChanRangeMin(int chan)
{
  EventTX_t etx;
  etx.event.cmd = QUERY;
  etx.event.data[0] = CHANRANGEMIN;
  etx.event.data[1] = chan; 

  return etx; 
}

EventTX_t queryChanRangeMax(int chan)
{
  EventTX_t etx;
  etx.event.cmd = QUERY;
  etx.event.data[0] = CHANRANGEMAX;
  etx.event.data[1] = chan; 

  return etx; 
}

chanrange_t chanRangeMin(const Event_t & evt)
{
  chanrange_t cr; 
  cr.first = evt.data[1]; 
  int32_t rmin(0); 
  rmin = evt.data[2]; 
  rmin = (rmin << 16) | evt.data[3]; 
  cr.second = rmin; 

  return cr; 
}

chanrange_t chanRangeMax(const Event_t & evt)
{
  chanrange_t cr; 
  cr.first = evt.data[1]; 
  int32_t rmax(0); 
  rmax = evt.data[2]; 
  rmax = (rmax << 16) | evt.data[3]; 
  cr.second = rmax; 

  return cr; 
}

std::list<eventcmd_t> cmdsToReceive()
{
  std::list<eventcmd_t> cmds; 
  cmds.push_back(QUERY); 
  cmds.push_back(SET); 
  cmds.push_back(RESPBCAST); 

}

PARAMETERS whichParam(const Event_t & event)
{
  switch(event.data[0]) {
  case LINKSTATUS:
    return LINKSTATUS; 
    break; 
  case MODE: 
    return MODE; 
    break; 
  case CHANGAIN:
    return CHANGAIN; 
    break; 
  case CHANHPF:
    return CHANHPF;
    break;
  case CHANSEL:
    return CHANSEL;
    break; 
  case CHANRANGEMIN:
    return CHANRANGEMIN;
    break; 
  case CHANRANGEMAX:
    return CHANRANGEMAX;
    break; 
  }
}

}

namespace TSpikeSink {

  PARAMETERS whichParam(const Event_t & event)
  {
    switch(event.data[0]) {
    case THRESHOLD:
      return THRESHOLD; 
      break; 
    case FILTERID: 
      return FILTERID; 
      break; 
    }
  }

  std::list<eventcmd_t> cmdsToReceive()
  {
    std::list<eventcmd_t> cmds; 
    cmds.push_back(QUERY); 
    cmds.push_back(SET); 
    cmds.push_back(RESPBCAST); 
  
  }

EventTX_t changeThreshold(chanthold_t ct)
{
  EventTX_t etx;
  etx.event.cmd = SET;
  etx.event.data[0] = THRESHOLD;
  etx.event.data[1] = ct.first; 
  etx.event.data[2] = (ct.second >> 16) & 0xFFFF; 
  etx.event.data[3] = ct.second & 0xFFFF; 
  return etx; 

}


chanthold_t changeThreshold(const Event_t & event)
{
  chanthold_t ct; 
  ct.first = event.data[1]; 
  uint32_t thold = 0; 
  thold = event.data[2]; 
  thold = (thold << 16) | event.data[3]; 
  ct.second = thold; 

  return ct; 

}

EventTX_t queryThold(int chan)
{
  EventTX_t etx;
  etx.event.cmd = QUERY;
  etx.event.data[0] = THRESHOLD; 
  etx.event.data[1] = chan; 

  return etx; 
}


EventTX_t changeFilterID(chanfiltid_t cfid)
{
  EventTX_t etx;
  etx.event.cmd = SET;
  etx.event.data[0] = THRESHOLD;
  etx.event.data[1] = cfid.first; 
  etx.event.data[2] = (cfid.second >> 16) & 0xFFFF; 
  etx.event.data[3] = cfid.second & 0xFFFF; 
  return etx; 

}


chanfiltid_t changeFilterID(const Event_t & event)
{
  chanfiltid_t cfid; 
  cfid.first = event.data[1]; 
  uint32_t filtid = 0; 
  filtid = event.data[2]; 
  filtid = (filtid << 16) | event.data[3]; 
  cfid.second = filtid; 

  return cfid; 

}

EventTX_t queryFiltid(int chan)
{
  EventTX_t etx;
  etx.event.cmd = QUERY;
  etx.event.data[0] = THRESHOLD; 
  etx.event.data[1] = chan; 

  return etx; 
}


}
}
}
