#include "memory.h"
void * operator new (size_t size)
{
  static void * pos = (void*) 0xff900000;  // we should really factor this out
  void * curpos = pos; 
  pos = (void*)((int)pos + size); 
  return curpos; 
}
