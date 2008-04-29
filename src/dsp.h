#ifndef DSP_H
#define DSP_H

enum DSP_POSITION { DSPA, DSPB, DSPC, DSPD, DSPNONE}; 

#define EADDR_TIMER 0
#define EADDR_SYSCONTROL 1
#define EADDR_NETWORK 3
#define EADDR_NETCONTROL 4 

class DSPConfig // ABC for all dsp configuration
{
  virtual DSP_POSITION getDSPPos() = 0; 
  virtual unsigned char getEventDevice() = 0; 
  virtual unsigned char getDataSrc() = 0; 
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

inline int encodeGain(char gval){

  switch(gval) {
  case 0: 
    return 0; 
  case 1:
    return 100; 
  case 2: 
    return 200; 
  case 3: 
    return 500; 
  case 4 : 
    return 1000; 
  case 5: 
    return 2000; 
  case 6 : 
    return 5000;
  case 7:
    return 10000; 
  default:
    return 0; 
  }
  

}
#endif // DSP_H
