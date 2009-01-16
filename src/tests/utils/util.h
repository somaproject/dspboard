#ifndef TEST_UTILS
#define TEST_UTILS

#include <filterio.h>
#include <systemtimer.h>
#include <fakesource.h>
#include <sinks/tspikesink.h>
#include <hostdataout.h>
#include <hw/eventtx.h>
#include <somanetwork/tspike.h>
#include <somanetwork/datapacket.h>


uint16_t * createEventBuffer(std::vector<bool> amask, std::vector<bool> bmask, 
			     std::vector<bool> cmask, std::vector<bool> dmask, 
			     std::vector<dsp::Event_t> events); 


#endif // TEST_UTISL
