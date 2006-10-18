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
  void sendCommand(const AcqCommand &); 

  //  void addSample(); 



  std::vector<int> gains_; 
  std::vector<bool> hpfs_; 
  int recentCMDID_; 
  
  AcqCommand acPending_; 
  int acDelaycnt_; 
  
  short fpos_; 
}; 


#endif // ACQSERIAL_H
