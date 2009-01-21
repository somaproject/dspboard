#ifndef MEMORY_H
#define MEMORY_H

// this is our custom new handler for small bits of memory

#include <sys/types.h>
#include <types.h>
#include <string.h>

void * operator new (size_t size); 
void * operator new[] (size_t size); 

uint32_t memory_in_use(); 



#include "byteswap.h"

class Memcopy {
public:
  static inline unsigned char *  hton_int32slow(unsigned char * dest, int32_t src) {
    /*
      copy the host-order int in src
      to the destination pointer dest in network byteorder

    */
    *(dest+3) = src & 0xFF; 
    src = src >> 8; 
    *(dest+2) = src & 0xFF; 
    src = src >> 8; 
    *(dest+1) = src & 0xFF; 
    src = src >> 8; 
    *dest = src & 0xFF; 
    return dest + 4; 

  }

  static inline unsigned char *  hton_int32(unsigned char * dest, int32_t src){
    /*
      copy the host-order int in src
      to the destination pointer dest in network byteorder
      
    */
    int x = __bswap_32(src); 
    *dest = x; 
    return dest + 4; 
    
  }


  static inline unsigned char *  hton_int16(unsigned char * dest, int32_t src){
    /*
      copy the host-order int in src
      to the destination pointer dest in network byteorder
      
    */
    int16_t x = __bswap_16(src); 
    *((int16_t *)(dest)) = x; 
    return dest + 2; 
    
  }



  static inline unsigned char *  hton_int64(unsigned char * dest, int64_t src) {
    /*
      assembly-optimized version

    */

    int64_t x = __bswap_64(src); 
    memcpy(dest, &x, sizeof(int64_t)); 
    
    return dest + sizeof(int64_t); 

  }

  static inline unsigned char *  hton_int32array(unsigned char * dest, int32_t * src, short len) 
  {
    /*
      src is a pointer to an array of 32-bit host-order ints
      dest is an arbitrary target pointer location (not necessarially aligned)
      len is the length 
      
      FIXME: figure out some way of optimizing if its aligned? 
      
    */
    for (int i = 0; i < len; i++) {
      int32_t srcval = *src; 
      dest = hton_int32(dest, srcval); 
      
      src++; 
      
    }
    return dest; 
    
  }
}; 


#endif // MEMORY_H
