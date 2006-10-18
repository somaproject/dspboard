#ifndef DSPDATAOUT_H
#define DSPDATAOUT_H



class DSPDataOut
{
 public:
  DSPDataOut(); 

  char outbuf[1000];
  void send(char * bufin, int N); 
  bool done(); 
  bool doneState; 

}; 

#endif // DSPDATAOUT_H
