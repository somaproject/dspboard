#include <iostream>
#include "readS3.h"
#include <boost/format.hpp>


using namespace std; 
using boost::format;
using boost::io::group;


int main(void) {
  
   readS3 s3mem; 
   if( s3mem.load("../DSPasm/DSPboard") == 0) {
     cout << "Successful load!!" << endl;
   } else {
     cout << "ERror!" << endl;
     return 0; 
   }

   memseg boot;
   boot = s3mem.range(0x84100, 0x84200); 
   memseg::iterator it;
   for (it = boot.begin(); it != boot.end(); ++it) {
     unsigned long long foo = it->second; 
     cout << boost::format("%08x %012x") % it->first % foo << endl;
   }
   
   
   
   cout << "dopnme " << endl; 
}
