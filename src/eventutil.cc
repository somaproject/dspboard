#include "eventutil.h"
namespace dspboard { 
uint16_t * createEventBuffer(std::vector<bool> amask, std::vector<bool> bmask, 
		       std::vector<bool> cmask, std::vector<bool> dmask, 
		       std::vector<dsp::Event_t> events)
{
  /* A helper function that creates a buffer and copies the relevant
     events into it for debugging
     
  */ 
  uint16_t * buffer = new uint16_t[512]; 
  for (int i = 0; i < 512; i++) 
    buffer[i] = 0; 

  buffer[0] = 0xBC00; 

  // A MASK

  for(int i = 0; i < 5; i++) {
    uint8_t byteh = 0; 
    uint8_t bytel = 0; 
    for (int j = 0; j < 8; j++) {
      if(amask[i * 16 + j]) {
	byteh |= (1 << j); 
      }
      
      if(amask[i * 16 + j + 8]) {
	bytel |= (1 << j); 
      }
    }
    
    buffer[i + 1] = (byteh << 8) | bytel; 
  }

  // B MASK

  for(int i = 0; i < 5; i++) {
    uint8_t byteh = 0; 
    uint8_t bytel = 0; 
    for (int j = 0; j < 8; j++) {
      if(bmask[i * 16 + j]) {
	byteh |= (1 << j); 
      }
      
      if(bmask[i * 16 + j + 8]) {
	bytel |= (1 << j); 
      }
    }
    
    buffer[i + 6] |= byteh; 
    buffer[i + 7] |= (bytel << 8); 
  }

  // C MASK

  for(int i = 0; i < 5; i++) {
    uint8_t byteh = 0; 
    uint8_t bytel = 0; 
    for (int j = 0; j < 8; j++) {
      if(cmask[i * 16 + j]) {
	byteh |= (1 << j); 
      }
      
      if(cmask[i * 16 + j + 8]) {
	bytel |= (1 << j); 
      }
    }
    buffer[i + 1 + 5 + 5 + 1] = (byteh << 8) | bytel; 
    

  }

  // D MASK

  for(int i = 0; i < 5; i++) {
    uint8_t byteh = 0; 
    uint8_t bytel = 0; 
    for (int j = 0; j < 8; j++) {
      if(dmask[i * 16 + j]) {
	byteh |= (1 << j); 
      }
      
      if(dmask[i * 16 + j + 8]) {
	bytel |= (1 << j); 
      }
    }
    
    buffer[i + 17] |= byteh; 
    buffer[i + 18] |= (bytel << 8); 
  }

  int bpos = 24; 
  for (std::vector<dsp::Event_t>::iterator i = events.begin(); i!= events.end(); i++)
    {
      uint16_t newcmd = (*i).cmd; 
      
      buffer[bpos] = (newcmd << 8 )| (*i).src; 
      bpos++; 
      for (int j = 0; j < 5; j++) {
	buffer[bpos] = (*i).data[j]; 
	bpos++; 
      }
    }
  return buffer; 

}
}
		
