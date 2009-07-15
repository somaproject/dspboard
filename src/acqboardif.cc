#include "acqboardif.h"

const int AcqState::RANGEMIN[8] = {0, 
				 -2048000, // gain = 100
				 -1024000, // gain = 200
				 -409600,  // gain = 500
				 -204800,  // gain = 1000
				 -102400,  // gain = 2000, 
				 -40960,   // gain = 5000, 
				 -20480};   // gain = 10000,
				 
const int AcqState::RANGEMAX[8] = {0, 
				 2048000, // gain = 100
				 1024000, // gain = 200
				 409600,  // gain = 500
				 204800,  // gain = 1000
				 102400,  // gain = 2000, 
				 40960,   // gain = 5000, 
				 20480};   // gain = 10000,
				 

