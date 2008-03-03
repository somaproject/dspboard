#include "memory.h"
void * operator new (size_t size)
{
  static void * pos = (void*) 0xff900000;  // we should really factor this out
  void * curpos = pos; 

  int nextpos = ((int)pos + size); 
  pos = (void*)nextpos; 
  return (void*)curpos; 
}

void * operator new[] (size_t size)
{
  // at the moment we allocate on 4-byte boundaries just to be safe
  static void * pos = (void*) 0xff900000;  // we should really factor this out
  void * curpos = pos; 

  int nextpos = ((int)pos + size); 
  pos = (void*)(( ( nextpos >> 2) + 1) << 2); // put things on 4-byte boundary 
  return curpos; 
}
