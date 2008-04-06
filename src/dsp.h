#ifndef DSP_H
#define DSP_H

enum DSP_POSITION { DSPA, DSPB, DSPC, DSPD, NONE}; 


class DSPConfig // ABC for all dsp configuration
{
  virtual DSP_POSITION getDSPPos() = 0; 
  virtual unsigned char getDevice() = 0; 
}; 




inline char decodeGain(short gain)
{
  switch(gain) {
  case 100: 
    return 1; 
  case 200: 
    return 2; 
  case 500:
    return 3; 
  case 1000:
    return 4; 
  case 2000: 
    return 5; 
  case 5000: 
    return 6; 
  case 10000: 
    return 7; 
  default:
    return 0; 
  }    
}
#endif // DSP_H
