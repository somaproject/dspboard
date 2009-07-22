#ifndef DSPBOARD_DSPDATAOUT_H
#define DSPBOARD_DSPDATAOUT_H

namespace dspboard { 

class DSPDataOut
{
 public:
  DSPDataOut(); 

  char outbuf[1000];
  void send(char * bufin, int N); 
  bool done(); 
  bool doneState; 

}; 

}

#endif // DSPDATAOUT_H
