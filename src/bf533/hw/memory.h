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

namespace dspboard { 

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

  static inline uint32_t  hton_int32slow(int32_t src) {
    /*
      copy the host-order int in src
      to the destination pointer dest in network byteorder

    */
    uint32_t result; 
    unsigned char * dest = (unsigned char*) &result; 
    *(dest+3) = src & 0xFF; 
    src = src >> 8; 
    *(dest+2) = src & 0xFF; 
    src = src >> 8; 
    *(dest+1) = src & 0xFF; 
    src = src >> 8; 
    *dest = src & 0xFF; 
    return result; 
  }

  static inline unsigned char *  hton_int32(unsigned char * dest, int32_t src){
    /*
      copy the host-order int in src
      to the destination pointer dest in network byteorder
      
    */
    int x = hton_int32(src); // __bswap_32_faster(src); 
    memcpy(dest, &x, 4); 
    return dest + 4; 
    
  }


  static inline int32_t hton_int32(int32_t src) {
    int32_t output; 
    __asm__("%0 = %1 >> 8 (V);" \
	    "%1 = %1 << 8 (V);" \
	    "%1 = %1 | %0;" \
	    "%0 = PACK(%1.L, %1.H);" \
	    : "=&d" (output),   "+d" (src)); 
    return output; 
  }
  
//   static inline int32_t hton_int32(int32_t src) {
//     int32_t output; 
//     __asm__("%1 = %0 >> 8 (V);" \
// 	    "%0 = %0 << 8 (V);" \
// 	    "%0 = %0 | %1;" \
// 	    "%1 = PACK(%0.L, %0.H);" \
// 	    : "+r" (src), "=&r"(output)); 
//     return output; 
//   }
  
//   static inline int32_t hton_int32(int32_t src) {
//     return __bswap_32_faster(src); 
//   }

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

  static inline unsigned char *  hton_int32array(unsigned char * dest, 
						 int32_t * src, short len) 
  {
    /*
      src is a pointer to an array of 32-bit host-order ints
      dest is an arbitrary target pointer location (not necessarially aligned)
      len is the length 
    
      will use optimized version if the dest address is aligned

    */
    if( ((uint32_t)dest & 0x3) == 0) {
      return (unsigned char*) hton_int32array_aligned((int32_t* )dest, src, len); 
      
    } else {
      return hton_int32array_unaligned(dest, src, len); 
    }
  }

  static inline unsigned char *  hton_int32array_unaligned(unsigned char * dest, 
						 int32_t * src, short len) 
  {
    /*
      src is a pointer to an array of 32-bit host-order ints
      dest is an arbitrary target pointer location (not necessarially aligned)
      len is the length 
    
      will use optimized version if the dest address is aligned

    */
    
      for(unsigned short i = 0; i < len; i++) {
	// attempt to use asm
	uint32_t x2 =  Memcopy::hton_int32(src[i]);
	memcpy(dest + i * sizeof(int32_t), &x2, sizeof(int32_t)); 

      }
      dest += (sizeof(int32_t) * len); 
      return dest; 

  }
  static inline int32_t *  hton_int32array_aligned(int32_t * dest, 
							int32_t * src, short len) 
  {
    /*
      src is a pointer to an array of 32-bit host-order ints
      dest is a 32-bit-aligned pointer location
      len is the length 
      returns 
      
    */
    int32_t * initdest = dest; 
    __asm__ __volatile__(
	    "I0 = %0;"
	    "I1 = %1;"
	    "R0 = [I1++];"
	    "R1 = R0 >> 8 (V);"
	    "R0 = R0 << 8 (V);"
	    "R0 = R0 | R1;"
	    "R2 = PACK(R0.L, R0.H); "
	    "R0 = [I1++];"
	    "LOOP dot%= LC0=%2;"
	    "LOOP_BEGIN dot%=;"
	    "R1 = R0 >> 8 (V) || [I0++] = R2;" 
	    "R0 = R0 << 8 (V);"
	    "R0 = R0 | R1;"
	    "R2 = PACK(R0.L, R0.H) || R0 = [I1++];"
	    "LOOP_END dot%=;" 
	    : 
	    :  "a"(dest), "a"(src), "a"(len)
	    : "I0", "I1", "R0", "R1", "R2", "P0", "memory"); 
    
    return initdest + len ; 
  }



}; 

}
#endif // MEMORY_H
