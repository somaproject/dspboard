#ifndef __VER_NOOP_H__
#define __VER_NOOP_H__

namespace dspboard { 

const uint16_t VERSION_MAJOR = 1; 
const uint16_t VERSION_MINOR = 0; 
const char * FIRMWARENAME = "    NOOP"; 
const uint64_t GITHASH = {{HASHSUB}}LLU; 
const uint32_t BUILDTIME = {{BUILDTIME}}; 

}

#endif
