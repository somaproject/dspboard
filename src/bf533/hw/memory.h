#ifndef MEMORY_H
#define MEMORY_H

// this is our custom new handler for small bits of memory

#include <sys/types.h>


void * operator new (size_t size); 
void * operator new[] (size_t size); 


#endif // MEMORY_H
