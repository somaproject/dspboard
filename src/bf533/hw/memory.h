#ifndef MEMORY_H
#define MEMORY_H

// this is our custom new handler for small bits of memory

#include <sys/types.h>


// int chunksize = 128; 

// extern "C" {
//   extern  char end;
// }

// void * operator new(size_t x) {
//   static char * pos = &end; 
//   char * oldpos = pos; 
//   pos += (x/4 + 1) * 4; 
//   return (void *) oldpos; 

// }

void * operator new (size_t size); 





#endif // MEMORY_H
