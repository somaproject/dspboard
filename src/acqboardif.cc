#include "acqboardif.h"

namespace dspboard {

const int AcqState::RANGEMIN[8] = {0, 
				 -20480000, // gain = 100
				 -10240000, // gain = 200
				 -4096000,  // gain = 500
				 -2048000,  // gain = 1000
				 -1024000,  // gain = 2000, 
				 -409600,   // gain = 5000, 
				 -204800};   // gain = 10000,
				 
  const int AcqState::RANGEMAX[8] = {0, 
				     20480000, // gain = 100
				     10240000, // gain = 200
				     4096000,  // gain = 500
				     2048000,  // gain = 1000
				     1024000,  // gain = 2000, 
				     409600,   // gain = 5000, 
				     204800};   // gain = 10000,
  

}
