#ifndef DSPBOARD_EVENTUTIL_H
#define DSPBOARD_EVENTUTIL_H

#include <vector>
#include "event.h" 
namespace dspboard { 
uint16_t * createEventBuffer(std::vector<bool> amask, std::vector<bool> bmask, 
			     std::vector<bool> cmask, std::vector<bool> dmask, 
			     std::vector<dsp::Event_t> events); 
}
#endif // EVENTUTIL_H
