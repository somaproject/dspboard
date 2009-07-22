#include "memory.h"
#define MEMORY_START 0xff900000



static void * memory_alloc_pos = (void*) MEMORY_START;  

void * operator new (size_t size)
{

  void * curpos = memory_alloc_pos; 

  int nextpos = ((int)memory_alloc_pos + size); 
  memory_alloc_pos = (void*)nextpos; 
  return (void*)curpos; 
}

void * operator new[] (size_t size)
{
  // at the moment we allocate on 4-byte boundaries just to be safe
  //static void * pos = (void*) 0xff900000;  // we should really factor this out
  void * curpos = memory_alloc_pos; 

  int nextpos = ((int)memory_alloc_pos + size); 
  memory_alloc_pos = (void*)(( ( nextpos >> 2) + 1) << 2); // put things on 4-byte boundary 
  return curpos; 
}

uint32_t memory_in_use()
{

  uint32_t x = (int)memory_alloc_pos - MEMORY_START; 
  return x; 

}

