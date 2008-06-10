#ifndef TYPES_H
#define TYPES_H

#include </usr/include/stdint.h>


class Memcopy {
public:
  static inline unsigned char *  hton_int32(unsigned char * dest, int32_t src) {
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

  static inline unsigned char *  hton_int64(unsigned char * dest, int64_t src) {
    /*
      copy the host-order int in src
      to the destination pointer dest in network byteorder
    */

    *(dest+7) = src & 0xFF; 
    src = src >> 8; 
    *(dest+6) = src & 0xFF; 
    src = src >> 8; 
    *(dest+5) = src & 0xFF; 
    src = src >> 8; 
    *(dest+4) = src & 0xFF; 
    src = src >> 8; 
    *(dest+3) = src & 0xFF; 
    src = src >> 8; 
    *(dest+2) = src & 0xFF; 
    src = src >> 8; 
    *(dest+1) = src & 0xFF; 
    src = src >> 8; 
    *dest = src & 0xFF; 
    return dest + 8; 

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
      hton_int32(dest, srcval); 
      
      dest += 4; 
      
      src++; 
      
    }
    return dest; 
    
  }
}; 
#endif
