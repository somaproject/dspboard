#ifndef ACQSERIAL_H
#define ACQSERIAL_H

#include <acqboardif.h>
#include <vector>


class AcqSerial: public AcqSerialBase
{
public: 
  AcqSerial(); 
  ~AcqSerial(); 
  
  bool checkRxEmpty(); 
  void getNextFrame(AcqFrame *); 
  void sendCommand(AcqCommand *); 
  bool linkUp(); 

  bool linkUpState_; 
  //  void addSample(); 



  std::vector<int> gains_; 
  std::vector<bool> hpfs_; 
  int recentCMDID_; 
  int mode_; 

  AcqCommand acPending_; 
  int acDelaycnt_; 
  
  
  short fpos_; 
}; 


#endif // ACQSERIAL_H
