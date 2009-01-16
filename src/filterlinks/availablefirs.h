#ifndef AVAILABLE_FIRS_H
#define AVAILABLE_FIRS_H

#include "filterio.h"

class AvailableFIRs
{
public:
  // has event interface
  AvailableFIRs(); 
  
  static const int FILTERNUM = 10; 
  static const int MAXFILTERLEN = 255; 
  sample_t filters[FILTERNUM][MAXFILTERLEN]; 
  unsigned char filterlens[FILTERNUM]; 
  bool filterset[FILTERNUM]; 
  filterid_t filterids[FILTERNUM]; 

}; 


#endif // AVAILABLE_FIRS_H
