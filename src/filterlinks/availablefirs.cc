#include "availablefirs.h"

AvailableFIRs::AvailableFIRs()
{
  // FIXME : RESET
  for(int i = 0; i < FILTERNUM; i++) {
    filterlens[i] = 0; 
    filterset[i] = false; 
    filterids[i] = 0; 
    for (int j = 0; j < MAXFILTERLEN; j++) {
      filters[i][j] = 0; 
    }
    
  }
}
