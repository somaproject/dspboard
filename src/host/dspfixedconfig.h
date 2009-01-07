#ifndef DSPFIXEDCONFIG_H
#define DSPFIXEDCONFIG_H


class DSPFixedConfig : public DSPConfig
{
public:

  DSPFixedConfig(DSP_POSITION pos, unsigned char event, unsigned char data) :
    pos_(pos), 
    event_(event), 
    data_(data)
  {
  }

  DSP_POSITION getDSPPos()
  {
    return pos_; 
  }
  unsigned char getEventDevice()
  {
    return event_; 
  }

  unsigned char getDataSrc()
  {
    return data_; 
  }
  DSP_POSITION pos_; 
  unsigned char event_; 
  unsigned char data_; 
  
}; 


#endif // DSPFIXEDCONFIG_H
